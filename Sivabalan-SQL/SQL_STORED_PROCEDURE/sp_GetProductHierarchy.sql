CREATE PROCEDURE sp_GetProductHierarchy(@ProductHierarchy nVarchar(50))
As
IF @ProductHierarchy = '%'
BEGIN
	INSERT INTO #tempCategory(CategoryID, CategoryName)
	SELECT CategoryID, Category_Name FROM ItemCategories
	WHERE ItemCategories.Level = (SELECT Max([Level]) FROM itemcategories)
END
ELSE
BEGIN
	INSERT INTO #tempCategory(CategoryID, CategoryName)
	SELECT CategoryID, Category_Name FROM ItemCategories, ItemHierarchy 
	WHERE ItemCategories.Level = ItemHierarchy.HierarchyId And
	ItemHierarchy.HierarchyName Like @ProductHierarchy
END


