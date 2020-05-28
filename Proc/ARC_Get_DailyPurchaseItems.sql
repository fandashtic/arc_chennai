--exec ARC_Get_DailyPurchaseItems '2020-03-16 00:00:00','2020-03-16 23:59:59'
Exec ARC_Insert_ReportData 626, 'Daily Purchase Items', 1, 'ARC_Get_DailyPurchaseItems', 'Click to view Daily Purchase Items', 417, 1,1,2,0,0,200,0,0,0,170, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_DailyPurchaseItems')
BEGIN
    DROP PROC [ARC_Get_DailyPurchaseItems]
END
GO
CREATE procedure [dbo].[ARC_Get_DailyPurchaseItems] (@FromDATE DATETIME,@ToDATE DATETIME)
As
Begin
	Set DateFormat DMY

	Exec SP_ARC_ResolveProduct_Mappings

	SELECT
	BA.BillDate,
	BD.Product_Code,	
	SUM(BD.Quantity) Quantity,
	MIN(BD.PurchasePrice) PurchasePrice,
	SUM(BD.Amount) [NetAmount]

	INTO #Temp

	FROM BillAbstract BA WITH (NOLOCK)
	JOIN BillDetail BD WITH (NOLOCK) ON BD.BillID = BA.BillID	
	Where Convert(Nvarchar(10),BA.BillDate,103) between @Fromdate and @Todate
	GROUP BY BA.BillDate,
	BD.Product_Code

	SELECT 1,
	T.BillDate,
	T. Product_Code,	
	I.ProductName,
	dbo.fn_Arc_GetCategoryGroup(P.CategoryGroup) [CATEGORY GROUP], 
	dbo.fn_Arc_GetCategory(P.Category) CATEGORY, 
	dbo.fn_Arc_GetItemFamily(P.ItemFamily) [ITEM FAMILY], 
	dbo.fn_Arc_GetItemSubFamily(P.ItemSubFamily) [ITEM SUB FAMILY], 
	dbo.fn_Arc_GetItemGroup(P.ItemGroup) [ITEM GROUP],
	ISNULL(CAST(CAST((ISNULL(T.Quantity, 0) / CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0) [Total Packs],
	ISNULL(CAST(CAST((ISNULL(T.PurchasePrice, 0) * CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0) [Pack Value],
	T.[NetAmount]  [Total Value]

	FROM #Temp T WITH (NOLOCK)
	JOIN Items I WITH (NOLOCK) ON I.Product_Code = T.Product_Code
	LEFT OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.Product_Code
	
End
SET QUOTED_IDENTIFIER OFF
GO

