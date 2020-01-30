Create Procedure mERP_Spr_ListMarginUpdationDetail(@MarginID nvarchar(50))
As
Declare @ProductHierarchy as nvarchar(50)
Declare @Mid as int
Declare @Category as nvarchar(150)
Declare @Delimeter as char(1)
Declare @Pos as int
declare @ProdHierarchy as nvarchar(255)
Begin
	set dateformat dmy
	set @Delimeter=char(15)
	
	select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=3
    
	set @Pos = charindex(char(15), @MarginID)  
	Set @Mid = Cast(SubString(@MarginID, 1, @Pos-1) as int)  
	Set @Category = Cast(SubString(@MarginID, @Pos+1, len(@MarginID)) as nvarchar) 

	Create table #tempCategory(CategoryID int,Status int)
	exec dbo.GetLeafCategories @ProdHierarchy,@Category
	select Product_Code,"Item Code" = Product_Code,
    "Item Name" = ProductName,
    "PTS" = PTS,
    "Current PTR" = PTR,
    "Margin %" = Percentage,
    "Effective From Date" = EffectiveDate,
    "New PTR" = PTR  + ((Percentage/100)*PTS)
    from Items,MarginDetail ,ItemCategories
    where Items.CategoryID in (select CategoryID from #tempCategory)
	and MarginID=@Mid
    and ItemCategories.Category_Name=@Category
    and MarginDetail.CategoryID=ItemCategories.CategoryID
    and Items.Active=1
	truncate table #tempCategory	
	drop table #tempCategory
End
