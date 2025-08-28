use DaHubInventory
go

drop proc if exists dbo.spGetBcbsApprovedStructuredData_UnpivotRownumberPivot;
go

create proc dbo.spGetBcbsApprovedStructuredData_UnpivotRownumberPivot(
    @mrn varchar(50),
    @visit1 varchar(50) = null,
    @visit2 varchar(50) = null,
    @visit3 varchar(50) = null,
    @visit4 varchar(50) = null,
    @visit5 varchar(50) = null,
    @visit6 varchar(50) = null,
    @visit7 varchar(50) = null,
    @visit8 varchar(50) = null,
    @visit9 varchar(50) = null,
    @visit10 varchar(50) = null,
    @visit11 varchar(50) = null
)
as 
begin
	select 
			MRN,
			[1] Visit1,[2] Visit2,[3] Visit3,[4] Visit4,[5] Visit5,
			[6] Visit6,[7] Visit7,[8] Visit8,[9] Visit9,[10] Visit10,
			[11] Visit11
		from 
		(
			select 
				MRN, VisitDates, 
				RowNum = ROW_NUMBER() over(partition by MRN order by VisitDates asc)
			from 
			(
				select @mrn MRN, 
					convert(date,isnull(@visit1,'')) v1, 
					convert(date,isnull(@visit2,'')) v2, 
					convert(date,isnull(@visit3,'')) v3, 
					convert(date,isnull(@visit4,'')) v4, 
					convert(date,isnull(@visit5,'')) v5, 
					convert(date,isnull(@visit6,'')) v6, 
					convert(date,isnull(@visit7,'')) v7, 
					convert(date,isnull(@visit8,'')) v8, 
					convert(date,isnull(@visit9,'')) v9, 
					convert(date,isnull(@visit10,'')) v10, 
					convert(date,isnull(@visit11,'')) v11
			) p
			unpivot (
				VisitDates for y in (v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11)
			) as unpvt
			where unpvt.VisitDates > '1900-01-01'
		)p
		pivot 
		(
			max(VisitDates)
			for RowNum in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11])
		) pvt

end
go

exec dbo.spGetBcbsApprovedStructuredData_UnpivotRownumberPivot '1234', 
		'2021-01-01', '', '2021-02-01', null, '2022-01-01', 
		'2023-01-01', '', '2023-02-01', null, '2024-01-01', 
		'2025-03-01'
