--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
create ProcEDURE sprc_recursive_sales_total(@CategoryID int,
				      @BeatID int,
				      @CustomerID nvarchar(15),
				      @FromDate datetime,
				      @ToDate datetime)
AS
create table #temptable(TotalValue Decimal(18,2) null)
exec sprc_recursive_Sales @CategoryID, @BeatID, @CustomerID, @FromDate, @ToDate
select isnull(sum(TotalValue),0) from #temptable
drop table #temptable

