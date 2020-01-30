CREATE procedure [dbo].[spc_category]
AS
SELECT a.Category_Name, a.Description, b.Category_Name, a.Track_Inventory, a.Price_Option, a.Active
FROM ItemCategories a, ItemCategories b
WHERE a.ParentID *= b.CategoryID
