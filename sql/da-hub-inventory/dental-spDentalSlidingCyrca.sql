
use DaHubInventory
go

drop proc if exists dbo.spDentalSlidingCyrca;
go
CREATE procedure dbo.spDentalSlidingCyrca 
	(
		@startdate varchar(10) , 
		@enddate varchar(10), 
		@insurance nvarchar(30)
	)
as begin
	--declare @startdate DATE = '06-01-2021', @enddate DATE = '6-30-2021', @insurance nvarchar(30) = 'sliding';
	SELECT [PatientID]
		  ,[LastName] + ', ' + [Firstname] Name
		  ,[BirthDate]
		  ,[Gender]
		  ,[Race]
		  ,[ClinicName]
		  ,[Insurance]
		  ,[ServiceDate]
		  ,[ADACode]
	  FROM [CpsWarehouse].[cps_den].[SlidingFeeCyrca]
	  where [ServiceDate] >= @startdate AND [ServiceDate] <= @enddate
	  AND (
			(@insurance like '%Cyrca%' AND INSID IN (1000106,1000108,1000127,1000431,1000638,1000655,1000656) )
			or
			(@insurance like '%Sliding%' AND INSID IN (1000004,1000003,1000005,1000006,1000007) )
			or
			(@insurance = ('Sliding,Cyrca') AND INSID IN (1000004,1000003,1000005,1000006,1000007,1000106,1000108,1000127,1000431,1000638,1000655,1000656) )
		) 
end

go
