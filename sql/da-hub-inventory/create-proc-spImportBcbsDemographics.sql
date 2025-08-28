
use DaHubInventory
go

drop proc if exists dbo.spImportBcbsDemographics;
go
create proc dbo.spImportBcbsDemographics (
	@HmsaMemberId varchar(100),
	@HmsaName varchar(100),
	@HmsaDoB varchar(100),
	@HmsaSubscriberId varchar(100),
	@HmsaGender varchar(100),
	@HmsaAddr1 varchar(100),
	@HmsaAddr2 varchar(100),
	@HmsaCity varchar(100),
	@HmsaState varchar(100),
	@HmsaZip varchar(100),
	@HmsaPhone varchar(100)
) 
as
begin
	declare @today date = convert(date, getdate() );

	with [source] 
		(
			[HmsaMemberId],[HmsaName],[HmsaDoB],[HmsaSubscriberId],[HmsaGender]
		  ,[HmsaAddr1],[HmsaAddr2],[HmsaCity],[HmsaState],[HmsaZip]
		  ,[HmsaLast],[HmsaFirst]
		 ) as
		 (
			select @HmsaMemberId,@HmsaName,convert(date,@HmsaDoB),@HmsaSubscriberId,@HmsaGender,
				@HmsaAddr1,@HmsaAddr2,@HmsaCity,@HmsaState,@HmsaZip,
				trim( substring(@HmsaName, 1,  charindex(',',@HmsaName) -1 )),
				trim( substring(@HmsaName,charindex(',',@HmsaName) + 1, len(@HmsaName) - charindex(',',@HmsaName) ) ) 
		 )
	merge athenaone.dbo.[all-hmsa] with (holdlock) as [target]
		using [source] on [source].[HmsaMemberId] = [target].[HmsaMemberId]

	when matched and
		[target].[HmsaName] <> [source].[HmsaName]
		or convert(date,[target].[HmsaDoB]) <> convert(date,[source].[HmsaDoB])
		or [target].[HmsaSubscriberId] <> [source].[HmsaSubscriberId]
		or [target].[HmsaGender] <> [source].[HmsaGender]
		or [target].[HmsaAddr1] <> [source].[HmsaAddr1]
		or isnull([target].[HmsaAddr2],'') <> isnull([source].[HmsaAddr2],'')
		or [target].[HmsaCity] <> [source].[HmsaCity]
		or [target].[HmsaState] <> [source].[HmsaState]
		or [target].[HmsaZip] <> [source].[HmsaZip]
		--or isnull([target].[HmsaPhone],'') <> isnull([source].[HmsaPhone],'')
	then update set
		[target].[HmsaName] = @HmsaName,
		[target].[HmsaDoB] = convert(date,@HmsaDoB),
		[target].[HmsaSubscriberId] = @HmsaSubscriberId,
		[target].[HmsaGender] = @HmsaGender,
		[target].[HmsaAddr1] = @HmsaAddr1,
		[target].[HmsaAddr2] = @HmsaAddr2,
		[target].[HmsaCity] = @HmsaCity,
		[target].[HmsaState] = @HmsaState,
		[target].[HmsaZip] = @HmsaZip,
		--[target].[HmsaPhone] = @HmsaPhone,
		HmsaModifiedDate = @today
		--[DateAdded] = @today
		
	when not matched by target then
		insert(
			[HmsaMemberId],[HmsaName],[HmsaDoB],[HmsaSubscriberId],[HmsaGender]
			,[HmsaAddr1],[HmsaAddr2],[HmsaCity],[HmsaState],[HmsaZip]
			,[HmsaLast],[HmsaFirst]
			,HmsaAddedDate
		 )
		values(
			@HmsaMemberId,@HmsaName,convert(date,@HmsaDoB),@HmsaSubscriberId,@HmsaGender,
			@HmsaAddr1,@HmsaAddr2,@HmsaCity,@HmsaState,@HmsaZip,
			trim( substring(@HmsaName, 1,  charindex(',',@HmsaName) -1 )),
			trim( substring(@HmsaName,charindex(',',@HmsaName) + 1, len(@HmsaName) - charindex(',',@HmsaName) ) ),
			@today
		);


end
go

select top 10 * from athenaone.dbo.[all-hmsa]
go
