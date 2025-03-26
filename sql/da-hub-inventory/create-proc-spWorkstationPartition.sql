use DaHubInventory
go

drop proc if exists dbo.spWorkstationPartition
go
create proc dbo.spWorkstationPartition
(
    @ComputerName varchar(50),
	@PartitionNumber  varchar(50) = null,
    @DiskNumber  varchar(50) = null,
    @IsBoot  varchar(50) = null,
    @IsHidden  varchar(50) = null,
    @IsSystem  varchar(50) = null,
    @IsReadOnly  varchar(50) = null,
    @IsOffline  varchar(50) = null,
    @IsActive  varchar(50) = null,
    @DriveLetter  varchar(50) = null,
    @PartitionSizeGb  varchar(50) = null
)
as 
begin
	declare @now datetime2 = getdate();

	--update existing Computers
	update dbo.WorkstationPartition
	set
		DiskNumber = @DiskNumber,
        IsBoot = convert(bit,@IsBoot),
        IsHidden = convert(bit,@IsHidden),
        IsSystem = convert(bit,@IsSystem),
        IsReadOnly = convert(bit,@IsReadOnly),
        IsOffline = convert(bit,@IsOffline),
        IsActive = convert(bit,@IsActive),
        DriveLetter = @DriveLetter,
        PartitionSizeGb = convert(float,@PartitionSizeGb),
		PartitionScanSuccessDate = @now
	where ComputerName = @ComputerName and PartitionNumber = @PartitionNumber;

	if @@ROWCOUNT = 0
	begin
		insert into dbo.WorkstationPartition(ComputerName, 
                PartitionNumber,
                DiskNumber, IsBoot, IsHidden, IsSystem, IsReadOnly, IsOffline, IsActive, DriveLetter, PartitionSizeGb,
                PartitionScanSuccessDate)
		select @ComputerName,
            convert(int,@PartitionNumber),
            convert(int,@DiskNumber), convert(bit,@IsBoot), convert(bit,@IsHidden), convert(bit,@IsSystem), convert(bit,@IsReadOnly), convert(bit,@IsOffline), convert(bit,@IsActive), @DriveLetter, convert(float,@PartitionSizeGb),
            @now
	end

end

go
select * from dbo.WorkstationPartition
go