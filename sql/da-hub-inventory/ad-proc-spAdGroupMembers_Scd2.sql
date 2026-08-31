
use DaHubInventory
go

drop proc if exists dbo.spAdGroupMembers_Scd2;
go

create proc dbo.spAdGroupMembers_Scd2
	@groupmembers dbo.tvpAdGroupMembers readonly
as
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try 
		-- Guard: reject duplicate
		if exists (
			select GroupSamAccountName, Username
			from @groupmembers
			where GroupSamAccountName is not null and Username is not null
			group by GroupSamAccountName, Username
			having count(*) > 1
		)
		begin;
			throw 51001, 'Custom exception: duplicate GroupSamAccountName, Username found in source', 1;
		end
		;

		-- Guard: reject null
		if exists (select 1 from @groupmembers where GroupSamAccountName is null or Username is null)
		begin;
			throw 51001, 'Custom exception: GroupSamAccountName and ServicName canot be NULL',1;
		end;

		-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
		drop table if exists #sourceHashedParameter;
		select 
			GroupSamAccountName, 
			Username, 
			convert(varchar,ObjectClass) ObjectClass,

			RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(GroupSamAccountName,''))), 
							lower(convert(varchar,isnull(Username,''))),
							lower(convert(varchar,isnull(ObjectClass,'')))
						)
					)
		into #sourceHashedParameter
		from @groupmembers;


		/*reset everything, start over - TO DO expire date = last serice scan date if computer other services were scanned after
		1. update rowhash
		2. expireDate = null
		3. last row for (computer, partition-number) tuple is current
		*/
		declare @reset int = 0;
		if @reset = 1
		begin
			-- Step-0.1: Reset all record > IsCurrent=0 && ExpiryDate=null && update rowhash
			begin try
				begin transaction;

				update gm
				set gm.IsCurrent = 0,
					gm.ExpiryDate = null,
					gm.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
					RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(GroupSamAccountName,''))), 
							lower(convert(varchar,isnull(Username,''))),
							lower(convert(varchar,isnull(ObjectClass,'')))
						)
					)
				from dbo.AdGroupMembers gm;

				commit transaction;
			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;

	
			-- Step-0.2: Latest record to IsCurrent=1 -> lastest record of computer name & partition-number name tuple
			begin try
				begin transaction;

				;with cte as (
					select gm.*, 
						RowNum = ROW_NUMBER() over(partition by GroupSamAccountName, Username order by AdGroupMemberScanSuccessDate desc) 
					from dbo.AdGroupMembers gm
				
				) 
					update c	
						set c.IsCurrent = 1,
							c.SlowlyChangingDimensionReason = 'manual-step-0.2-activate-lastest-row->IsCurrent=1'
					from cte c
					where RowNum = 1;

				commit transaction;

			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;

			-- Step-0.3: Older record to IsCurrent=0 && add expiration date -> lastest record of computer name & partition-number name tuple 
			begin try
				begin transaction;
					;with cte as (
						select gm.*, 
							RowNum = ROW_NUMBER() over(partition by GroupSamAccountName, Username order by AdGroupMemberScanSuccessDate desc) 
						from dbo.AdGroupMembers gm
				
					) 
						update c	
							set c.IsCurrent = 0,
								c.ExpiryDate = convert(date,getdate()),
								c.SlowlyChangingDimensionReason = 'manual-step-0.3-deactivate-old-record->add-expiry-date->IsCurrent=0-&&-expiration-date'
						from cte c
						where c.IsCurrent != 1

				commit transaction;
			end try
			begin catch
				if @@trancount > 0 rollback transaction;
				throw;
			end catch;



			-- count
			select SlowlyChangingDimensionReason, count(*) 
			from dbo.AdGroupMembers
			group by SlowlyChangingDimensionReason;


		end
		;

		
		/* 6 possibility
			-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			-- scenario-2:destination-is-null->new-partition-number-found->insert
			-- scenario-3:hash-match-&&-IsCurrent=1->no-change
			-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			-- scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
			-- step 5.1: change those to not current
			-- step 5.2: insert new
			-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
		*/
		;

		begin try 
			begin transaction;

			-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0'
			from dbo.AdGroupMembers dst
			where dst.IsCurrent = 1
				and dst.GroupSamAccountName in (select distinct GroupSamAccountName from #sourceHashedParameter)
				and not exists (
						select 1 
						from #sourceHashedParameter src
						where src.GroupSamAccountName = dst.GroupSamAccountName
							and src.Username = dst.Username
					)
			;

				
			-- scenario-2:destination-is-null->new-partition-number-found->insert
			insert into dbo.AdGroupMembers(
					GroupSamAccountName,Username,ObjectClass,
					AdGroupMemberScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				GroupSamAccountName,Username,ObjectClass,
				@now,
				@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-partition-number-found->insert'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdGroupMembers dst
						where dst.GroupSamAccountName = src.GroupSamAccountName
							and dst.Username = src.Username
							and dst.IsCurrent = 1
					)
			;

			-- scenario-3:hash-match-&&-IsCurrent=1->no-change
			update dst	
				set AdGroupMemberScanSuccessDate = @now,
					SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
			from dbo.AdGroupMembers dst
				inner join #sourceHashedParameter src on src.GroupSamAccountName = dst.GroupSamAccountName and src.Username = dst.Username and src.rowhash = dst.RowHash
			where dst.IsCurrent = 1
			;

			-- scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			;


			-- scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
			-- step 5.1: hash no-match -> priter status changed -> set-IsCurrent=0 && add expiration date
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'step 5.1: hash no-match -> partition-number drive or IP changed -> set-IsCurrent=0 && add expiration date'
			from dbo.AdGroupMembers dst
				inner join #sourceHashedParameter src on src.GroupSamAccountName = dst.GroupSamAccountName and src.Username = dst.Username 
			where dst.IsCurrent = 1
				and src.rowhash <> dst.RowHash
			;

			-- step 5.2: hash no-match -> removed old row -> now insert new
			insert into dbo.AdGroupMembers(
					GroupSamAccountName,Username,ObjectClass,
					AdGroupMemberScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				GroupSamAccountName,Username,ObjectClass,
				@now,
				@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdGroupMembers dst
						where dst.GroupSamAccountName = src.GroupSamAccountName
							and dst.Username = src.Username
							and dst.IsCurrent = 1
					)
			;

			-- scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			;
			

			commit transaction;
		end try
		begin catch
			if @@trancount > 0 rollback transaction;
			throw;
		end catch;
		;




	end try
	begin catch
		if @@trancount > 0 rollback transaction;
		throw;
	end catch
	

end

go

select * 
from dbo.AdGroupMembers
go
