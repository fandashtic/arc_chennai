 --Select * from V_ARC_Items_BatchDetails T WHERE T.Product_Code = 'FD2125N' AND CAST(T.Batch_Code AS VARCHAR(255)) = '06A300719-30'
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
	dbo.fn_Arc_GetItemGroup(P.ItemGroup) ItemGroup
from Items I WITH (NOLOCK)
FULL OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.Product_Code
GO
