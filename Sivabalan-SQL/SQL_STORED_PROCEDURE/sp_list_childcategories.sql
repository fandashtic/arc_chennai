
CREATE PROC sp_list_childcategories
AS
SELECT Category_Name, CategoryID FROM ItemCategories
WHERE CategoryID Not In (Select Distinct ParentID FROM ItemCategories WHERE ParentID <> 0)
AND Active = 1

