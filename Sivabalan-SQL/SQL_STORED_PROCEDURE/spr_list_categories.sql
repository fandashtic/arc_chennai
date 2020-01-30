CREATE PROCEDURE [dbo].[spr_list_categories]
AS
Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)
Set @YES = dbo.LookupDictionaryItem(N'Yes',Default)
Set @NO = dbo.LookupDictionaryItem(N'No',Default)

SELECT a.CategoryID, "Category Name" = a.Category_Name, 
	"Description" = a.Description, "Parent" = b.Category_Name,
	"Track Inventory" = 
	CASE a.Track_Inventory
	WHEN 1 THEN @YES
	ELSE @NO
	END,
	"Capture Price" = 
	CASE a.Price_Option
	WHEN 1 THEN @YES
	ELSE @NO
	END
FROM ItemCategories a 
Left Outer Join ItemCategories b ON a.ParentID = b.CategoryID
WHERE a.ParentID = b.CategoryID
ORDER BY a.Category_Name, Parent
