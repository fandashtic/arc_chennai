CREATE procedure sp_get_splcatdetail(@nSplcatCode Int)
as
If (Select distinct CategoryType From Special_Category Where Special_Cat_Code = @nSplcatcode) = 1 
Begin 
select [ID]=Special_Cat_Product.Special_Cat_Code,
[Name]=(select Special_Category.[Description] from Special_Category where Special_Cat_Code = @nSplcatcode),
ProductCode=items.alias,CategoryName=NULL,HierarchyId=itemHierarchy.HierarchyID,HierarchyName = ItemHierarchy.HierarchyName
From Special_Cat_Product, items, itemCategories, ItemHierarchy
Where items.product_code = Special_Cat_Product.Product_Code
and items.CategoryID = itemCategories.CategoryID
and itemCategories.[Level] = Itemhierarchy.hierarchyID
and Special_Cat_Product.Special_Cat_code = @nSplcatcode
End
Else
Begin
select [ID]=Special_Cat_Product.Special_Cat_Code,
[Name]=(select Special_Category.[Description] from Special_Category where Special_Cat_Code = @nSplcatcode),
ProductCode=NULL,CategoryID=ItemCategories.CategoryID, CategoryName=itemCategories.Category_Name,
HierarchyId=itemHierarchy.HierarchyID,HierarchyName = ItemHierarchy.HierarchyName
From Special_Cat_Product, itemCategories, ItemHierarchy
Where itemCategories.[Level] = Itemhierarchy.hierarchyID
and itemCategories.CategoryID = special_Cat_Product.CategoryID
and Special_Cat_Product.Special_Cat_code = @nsplcatcode
End





