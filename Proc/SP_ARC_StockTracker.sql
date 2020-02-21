--exec SP_ARC_StockTracker 
Exec ARC_Insert_ReportData 562, 'Stock Tracker', 1, 'SP_ARC_StockTracker', 'Click to view Stock Tracker', 417, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_StockTracker')
BEGIN
    DROP PROC SP_ARC_StockTracker
END
GO
CREATE PROCEDURE [dbo].SP_ARC_StockTracker
AS
BEGIN
	SET DATEFORMAT DMY
	SELECT DISTINCT --Top 100
	1,
	Case 
		When ISNULL(P.Product_Code, '') <> '' THEN P.Product_Code 
		When ISNULL(S.Product_Code, '') <> '' THEN S.Product_Code 
		When ISNULL(SR.Product_Code, '') <> '' THEN SR.Product_Code 
	END Product_Code
	, I.ProductName
	, I.CategoryGroup
	, I.ItemFamily
	, I.ItemSubFamily
	,ISNULL(P.PurchaseQuantity, 0) / ISNULL(I.UOM2_Conversion, 1) [Purchase On Packs]
	,ISNULL(S.SalesQuantity, 0) / ISNULL(I.UOM2_Conversion, 1) [Sales On Packs]
	,ISNULL(SR.SRQuantity, 0) / ISNULL(I.UOM2_Conversion, 1) [Sales Return On Packs]
	,((ISNULL(P.PurchaseQuantity, 0) / ISNULL(I.UOM2_Conversion, 1) + ISNULL(SR.SRQuantity, 0) / ISNULL(I.UOM2_Conversion, 1)) - ISNULL(S.SalesQuantity, 0) / ISNULL(I.UOM2_Conversion, 1)) [Closing Packs]
	FROM 

	(select P.Product_Code, SUM(P.Quantity) [PurchaseQuantity]
	from V_ARC_Purchase_ItemDetails P WITH (NOLOCK) GROUP BY P.Product_Code) P

	FULL OUTER JOIN
	(select S.Product_Code,
	SUM(S.Quantity) [SalesQuantity]
	from V_ARC_Sale_ItemDetails S WITH (NOLOCK) GROUP BY S.Product_Code) S ON S.Product_Code = P.Product_Code

	FULL OUTER JOIN
	(select SR.Product_Code,
	SUM(SR.Quantity) [SRQuantity]
	from V_ARC_SaleReturn_ItemDetails  SR WITH (NOLOCK) GROUP BY SR.Product_Code) SR ON SR.Product_Code = P.Product_Code

	JOIN V_ARC_Items I WITH (NOLOCK) ON I.Product_Code = 
	(Case 
		When ISNULL(P.Product_Code, '') <> '' THEN P.Product_Code 
		When ISNULL(S.Product_Code, '') <> '' THEN S.Product_Code 
		When ISNULL(SR.Product_Code, '') <> '' THEN SR.Product_Code 
	END)
END
GO

