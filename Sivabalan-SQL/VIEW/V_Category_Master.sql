CREATE VIEW  [dbo].[V_Category_Master]
([Category_ID], [Category_name], [Parent_Category_ID], [Level], [Description],[Active])
AS
SELECT     CategoryID AS Category_ID, Category_Name, ParentID AS Parent_Category_ID, [Level], 
                      (CASE [Level] WHEN 2 THEN (CASE WHEN Description = '' OR Description is NULL THEN Category_Name ELSE description END) 
									WHEN 3 THEN (CASE WHEN Description = '' OR Description is NULL THEN Category_Name ELSE description END)
									ELSE [Description] END) AS Description, 
                      Active
FROM         dbo.ItemCategories
