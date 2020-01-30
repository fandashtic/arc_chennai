-------------------------------------------------------------------
create ProcEDURE sprc_recursive_sales(@CategoryID int,
				      @BeatID int,
				      @CustomerID nvarchar(15),
				      @FromDate datetime,
				      @ToDate datetime)
AS
DECLARE @NewCategoryID int
DECLARE @TotalSalesValue float

SET @NewCategoryID = (SELECT MIN(CategoryID) FROM ItemCategories WHERE ISNULL(ParentID, 0) = @CategoryID)

SET @TotalSalesValue = dbo.sprc_sales_by_ItemCategory_Beat_Value(@CategoryID, @BeatID, @CustomerID, @FromDate, @Todate)
IF @TotalSalesValue IS NOT NULL insert into #temptable values(@TotalSalesValue)
WHILE @NewCategoryID IS NOT NULL
BEGIN
	exec sprc_recursive_sales @NewCategoryID, @BeatID, @CustomerID, @FromDate, @ToDate
	SET @NewCategoryID = (SELECT MIN(CategoryID) FROM ItemCategories WHERE ISNULL(ParentID, 0) = @CategoryID And CategoryID > @NewCategoryID)
END

