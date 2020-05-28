--exec ARC_Get_DailySalesReturnItems '2020-03-15 00:00:00','2020-03-16 23:59:59'
Exec ARC_Insert_ReportData 625, 'Daily Sales Return Items', 1, 'ARC_Get_DailySalesReturnItems', 'Click to view Daily Sales Items', 561, 1,1,2,0,0,200,0,0,0,170, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_DailySalesReturnItems')
BEGIN
    DROP PROC [ARC_Get_DailySalesReturnItems]
END
GO
CREATE procedure [dbo].[ARC_Get_DailySalesReturnItems] (@FromDATE DATETIME,@ToDATE DATETIME)
As
Begin
	Set DateFormat DMY

	Exec SP_ARC_ResolveProduct_Mappings

	SELECT ID.Product_Code,
	SUM((CASE WHEN ISNULL(ID.SalePrice , 0) = 0 THEN ID.Quantity ELSE 0 END)) FreeQuantity,
	SUM(CASE WHEN ISNULL(ID.SalePrice, 0) = 0 THEN 0 ELSE ID.Quantity END) SalableQuantity,
	ID.SalePrice, SUM(ID.Amount) Amount,
	MIN(IA.InvoiceDate) InvoiceDate

	INTO #Data

	FROM InvoiceDetail ID WITH (NOLOCK),
	InvoiceAbstract IA WITH (NOLOCK)

	WHERE ID.InvoiceID = IA.InvoiceID And
	dbo.StripDateFromTime(IA.InvoiceDate) between @FromDATE AND @ToDATE
	AND ISNULL(IA.Status,0) & 128 = 0 AND
	IA.InvoiceType in (4)

	GROUP BY ID.Product_Code, ID.SalePrice


	--Insert Into #Temp
	SELECT 
	1,
	D.InvoiceDate,
	D.Product_Code, 
	I.ProductName,
	dbo.fn_Arc_GetCategoryGroup(P.CategoryGroup) [CATEGORY GROUP], 
	dbo.fn_Arc_GetCategory(P.Category) CATEGORY, 
	dbo.fn_Arc_GetItemFamily(P.ItemFamily) [ITEM FAMILY], 
	dbo.fn_Arc_GetItemSubFamily(P.ItemSubFamily) [ITEM SUB FAMILY], 
	dbo.fn_Arc_GetItemGroup(P.ItemGroup) [ITEM GROUP],
	ISNULL(
	(Case WHEN ISNULL(D.SalePrice, 0) > 0 THEN
	CAST(CAST((ISNULL(D.SalePrice, 0) * CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6)) AS Decimal(18,6))
	ELSE 0 END)
	, 0) [Pack Value],
	ISNULL(CAST(CAST((ISNULL(D.FreeQuantity, 0) / CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0) [Total Free Packs],
	ISNULL(CAST(CAST((ISNULL(D.SalableQuantity, 0) / CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0) [Total Salable Packs],
	(ISNULL(CAST(CAST((ISNULL(D.FreeQuantity, 0) / CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0) + 
	ISNULL(CAST(CAST((ISNULL(D.SalableQuantity, 0) / CASE WHEN dbo.fn_Arc_GetCategory(P.Category) = 'CG' THEN 1 ELSE ISNULL(I.UOM2_Conversion, 1) END) as Decimal(18,6))AS INT), 0)) [Total Packs],	
	D.Amount  [Total Value]
	
	FROM #Data D WITH (NOLOCK)
	JOIN Items I WITH (NOLOCK) ON I.Product_Code = D.Product_Code
	LEFT OUTER JOIN Product_Mappings P WITH (NOLOCK) ON P.Product_Code = I.Product_Code
	
	Drop table #Data
End
SET QUOTED_IDENTIFIER OFF
GO

