
Create Procedure sp_GetDefaultSalesUOM_ITC
As
Begin
Create Table #tmpUOM (UOM int, Description nvarchar(50), UOMConv decimal(18,6))

Declare @RowCount int
Declare @RowNum int
Declare @UOM int
Declare @UOMConv decimal(18,6)
Declare @Description nvarchar(50)
Declare @Product_Code nvarchar(30)

Insert into #temp (Product_Code) select product_Code from Items

Set @RowCount = (select max(RowNum) from #temp)
Set @RowNum = 1

While @RowNum <= @RowCount
Begin
	Set @Product_Code = (select Product_code from #temp where RowNum = @RowNum)
	Insert into #tmpUOM exec sp_get_Item_UOM @Product_Code

	Set @UOM = (select top 1 UOM from #tmpUOM)
	Set @UOMConv = (select top 1 UOMConv from #tmpUOM)
	Set @Description  = (select top 1 Description from #tmpUOM)

	Update #temp set UOM = @UOM where RowNum = @RowNum
	Update #temp set UOMConv = @UOMConv where RowNum = @RowNum
	Update #temp set [Description] = @Description where RowNum = @RowNum

	Set @RowNum = @RowNum + 1

	Truncate table #tmpUOM
End

drop table #tmpUOM
End


