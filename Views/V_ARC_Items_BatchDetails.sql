 --Select * from V_ARC_Items_BatchDetails T WHERE T.Product_Code = 'FD2125N' AND CAST(T.Batch_Code AS VARCHAR(255)) = '06A300719-30'
 IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'V_ARC_Items_BatchDetails')
BEGIN
    DROP VIEW V_ARC_Items_BatchDetails
END
GO
Create View V_ARC_Items_BatchDetails
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
	IC1.Category_Name [MarketSKU],
	B.Batch_Code,
	B.Batch_Number,
	B.Quantity,
	B.SalePrice,
	B.PurchasePrice,
	B.PTS,
	B.PTR,
	B.GRN_ID,
	B.Expiry,
	(CASE WHEN ISNULL(B.Damage, 0) > 0 THEN 1 ELSE 0 END) IsDamage,
	B.DamagesReason,
	B.UOMQty,
	B.CreationDate,
	(Case When ISNULL(I.UOM2_Conversion, 0) = 0 THEN 1 ELSE I.UOM2_Conversion END) ReportingUOM,
	DATEDIFF(d, B.CreationDate, Getdate()) [Aging]
from Items I WITH (NOLOCK)
FULL OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.Product_Code
FULL OUTER JOIN Batch_Products B WITH (NOLOCK) ON B.Product_Code = I.Product_Code
JOIN ItemCategories IC1 WITH (NOLOCK) ON I.CategoryID = IC1.CategoryID
JOIN ItemCategories IC2 WITH (NOLOCK) ON IC2.CategoryID = IC1.ParentID
JOIN ItemCategories IC3 WITH (NOLOCK) ON IC3.CategoryID = IC2.ParentID 
JOIN ItemCategories IC4 WITH (NOLOCK) ON IC4.CategoryID = IC3.ParentID
GO