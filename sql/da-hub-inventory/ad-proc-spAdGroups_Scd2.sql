

use DaHubInventory
go


drop proc if exists dbo.spAdGroups_Scd2
go
create proc dbo.spAdGroups_Scd2
	@groups dbo.tvpAdGroups readonly
as
begin
	set nocount on;
	declare @now datetime2 = getdate();

	begin try 
		-- Guard: reject duplicate
		if exists (
			select SamAccountName
			from @groups
			where SamAccountName is not null
			group by SamAccountName
			having count(*) > 1
		)
		begin;
			throw 51001, 'Custom exception: duplicate SamAccountName found in source', 1;
		end
		;

		-- Guard: reject null
		if exists (select 1 from @groups where SamAccountName is null)
		begin;
			throw 51001, 'Custom exception: SamAccountName canot be NULL',1;
		end;


		-- claude recommendation for SCD type 2: compute hash of incoming rows for fast comparison
		drop table if exists #sourceHashedParameter;
		select 
			convert(varchar,CanonicalName) CanonicalName,
			SamAccountName, 
			convert(varchar,Name) Name,
			convert(varchar,Mail) Mail,
			convert(varchar,DistinguishedName) DistinguishedName,
			convert(varchar,Description) Description,
			convert(datetime,CreatedDate) CreatedDate,
			convert(datetime,ModifiedDate) ModifiedDate,
			convert(varchar,GroupCategory) GroupCategory,
			convert(varchar,GroupScope) GroupScope,

			RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(SamAccountName,''))), 
							lower(convert(varchar,isnull(CanonicalName,''))),
							lower(convert(varchar,isnull(Name,''))),
							lower(convert(varchar,isnull(Mail,''))),
							lower(convert(varchar,isnull(DistinguishedName,''))),
							lower(convert(varchar,isnull(Description,''))),
							lower(convert(varchar,isnull(GroupCategory,''))),
							lower(convert(varchar,isnull(GroupScope,''))),
							lower(convert(varchar,isnull(CreatedDate,''))),
							lower(convert(varchar,isnull(ModifiedDate,'')))
						)
					)
		into #sourceHashedParameter
		from @groups;

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

				update ag
				set ag.IsCurrent = 0,
					ag.ExpiryDate = null,
					ag.SlowlyChangingDimensionReason = 'manual-step-0.1-reset-all->IsCurrent=0-&&-expiry=null',
					RowHash = hashbytes(
						'sha2_256', 
						concat(
							lower(convert(varchar,isnull(SamAccountName,''))), 
							lower(convert(varchar,isnull(CanonicalName,''))),
							lower(convert(varchar,isnull(Name,''))),
							lower(convert(varchar,isnull(Mail,''))),
							lower(convert(varchar,isnull(DistinguishedName,''))),
							lower(convert(varchar,isnull(Description,''))),
							lower(convert(varchar,isnull(GroupCategory,''))),
							lower(convert(varchar,isnull(GroupScope,''))),
							lower(convert(varchar,isnull(CreatedDate,''))),
							lower(convert(varchar,isnull(ModifiedDate,'')))
						)
					)
				from dbo.AdGroups ag;

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
					select ag.*, 
						RowNum = ROW_NUMBER() over(partition by SamAccountName order by AdGroupScanSuccessDate desc) 
					from dbo.AdGroups ag
				
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
						select ag.*, 
							RowNum = ROW_NUMBER() over(partition by SamAccountName order by AdGroupScanSuccessDate desc) 
						from dbo.AdGroups ag
				
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
			from dbo.AdGroups
			group by SlowlyChangingDimensionReason;


		end
		
		/* 6 possibility
			 scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			 scenario-2:destination-is-null->new-partition-number-found->insert
			 scenario-3:hash-match-&&-IsCurrent=1->no-change
			 scenario 4: hash match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
			 scenario 5: hash no match && IsCurrent=1 -> partition-number status changed
			 step 5.1: change those to not current
			 step 5.2: insert new
			 scenario 6: hash no match && IsCurrent = 0 -> dont look for this scenario. IsCurrent=0 means old 
		*/
		;

		begin try 
			begin transaction;

			-- scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0
			update dst 
				set IsCurrent = 0,
					ExpiryDate = @now,
					SlowlyChangingDimensionReason = 'scenario-1:source-is-null->partition-number-removed->set-IsCurrent=0'
			from dbo.AdGroups dst
			where dst.IsCurrent = 1
				and dst.SamAccountName in (select distinct SamAccountName from #sourceHashedParameter)
				and not exists (
						select 1 
						from #sourceHashedParameter src
						where src.SamAccountName = dst.SamAccountName
					)
			;
			
				
			-- scenario-2:destination-is-null->new-partition-number-found->insert
			insert into dbo.AdGroups(
					CanonicalName,sAMAccountName,Name,Mail,DistinguishedName,Description,
					GroupCategory,GroupScope,CreatedDate,ModifiedDate,
					AdGroupScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				CanonicalName,sAMAccountName,Name,Mail,DistinguishedName,Description,
				GroupCategory,GroupScope,CreatedDate,ModifiedDate,
				@now,
				@now, null, 1, RowHash, 'scenario-2:destination-is-null->new-partition-number-found->insert'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdGroups dst
						where dst.SamAccountName = src.SamAccountName
							and dst.IsCurrent = 1
					)
			;

			-- scenario-3:hash-match-&&-IsCurrent=1->no-change
			update dst	
				set AdGroupScanSuccessDate = @now,
					SlowlyChangingDimensionReason = 'scenario-3:hash-match-&&-IsCurrent=1->no-change'
			from dbo.AdGroups dst
				inner join #sourceHashedParameter src on src.SamAccountName = dst.SamAccountName and src.rowhash = dst.RowHash
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
			from dbo.AdGroups dst
				inner join #sourceHashedParameter src on src.SamAccountName = dst.SamAccountName
			where dst.IsCurrent = 1
				and src.rowhash <> dst.RowHash
			;

			-- step 5.2: hash no-match -> removed old row -> now insert new
			insert into dbo.AdGroups(
					CanonicalName,sAMAccountName,Name,Mail,DistinguishedName,Description,
					GroupCategory,GroupScope,CreatedDate,ModifiedDate,
					AdGroupScanSuccessDate,
					EffectiveDate, ExpiryDate, IsCurrent, RowHash, SlowlyChangingDimensionReason
				)
			select
				CanonicalName,sAMAccountName,Name,Mail,DistinguishedName,Description,
				GroupCategory,GroupScope,CreatedDate,ModifiedDate,
				@now,
				@now, null, 1, RowHash, 'step 5.2: hash no-match -> removed old row -> now insert new'
			from #sourceHashedParameter src
			where  not exists (
						select 1 
						from dbo.AdGroups dst
						where dst.SamAccountName = src.SamAccountName
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
go
select * from DaHubInventory.dbo.AdGroups where IsCurrent = 1 order by AdGroupScanSuccessDate desc
go