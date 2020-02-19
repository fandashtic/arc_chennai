 --Select * from V_ARC_Items T WHERE T.Product_Code = 'FD2125N' AND CAST(T.Batch_Code AS VARCHAR(255)) = '06A300719-30'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Items')
BEGIN
    DROP VIEW V_ARC_Items
END
GO
Create View V_ARC_Items
AS
SELECT 
	I.Product_Code,
	P.ProductName,
	dbo.fn_Arc_GetCategoryGroup(P.CategoryGroup) CategoryGroup, 
	dbo.fn_Arc_GetCategory(P.Category) Category, 
	dbo.fn_Arc_GetItemFamily(P.ItemFamily) ItemFamily, 
	dbo.fn_Arc_GetItemSubFamily(P.ItemSubFamily) ItemSubFamily, 
	dbo.fn_Arc_GetItemGroup(P.ItemGroup) ItemGroup,
	IC4.Category_Name [Manufacture],
	IC3.Category_Name [Division],
	IC2.Category_Name [SubCategory],
	IC1.Category_Name [MarketSKU]
from Items I WITH (NOLOCK)
JOIN ItemCategories IC1 WITH (NOLOCK) ON I.CategoryID = IC1.CategoryID
JOIN ItemCategories IC2 WITH (NOLOCK) ON IC2.CategoryID = IC1.ParentID
JOIN ItemCategories IC3 WITH (NOLOCK) ON IC3.CategoryID = IC2.ParentID 
JOIN ItemCategories IC4 WITH (NOLOCK) ON IC4.CategoryID = IC3.ParentID
FULL OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.Product_Code
GO
