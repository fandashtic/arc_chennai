Create Procedure mERP_Sp_ListItem(@ProductHierarchy nvarchar(255),@Category nvarchar(2550))
As
declare @ProdHierarchy as nvarchar(255)
Begin
	Create table #tempCategory(CategoryID int,Status int)
	If @ProductHierarchy=N'Sub_Category'
        select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=3
    Else if @ProductHierarchy=N'Division'
		select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=2
	exec dbo.GetLeafCategories @ProdHierarchy,@Category
	select Product_Code,ProductName,PTS,PTR,ECP from Items where 
    CategoryID in (select CategoryID from #tempCategory)
    and Active=1
	truncate table #tempCategory	
	drop table #tempCategory
End
