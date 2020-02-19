--exec SP_ARC_StockBatchAging
--Exec ARC_Insert_ReportData 559, 'Stock Batch Aging', 1, 'SP_ARC_StockBatchAging', 'Click to view Stock Batch Aging', 70, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_StockBatchAging')
BEGIN
    DROP PROC SP_ARC_StockBatchAging
END
GO
CREATE PROCEDURE [dbo].SP_ARC_StockBatchAging     
AS
BEGIN
	select 1, 
	V.Product_Code,	
	V.ProductName,
	V.CategoryGroup,
	V.Category,
	V.ItemFamily,
	V.ItemSubFamily,
	V.Batch_Code,
	V.Batch_Number,	
	(ISNULL(V.Quantity, 0) / ISNULL(V.ReportingUOM, 1)) [Current Quantity],
	V.PurchasePrice	,
	V.PTR [SalePrice],
	(case When isnull(V.IsDamage, 0) <> 0 THEN  
	(select Top 1 R.Reason_Description FROM V_Reason_Master R WHERE R.Reason_Type_ID = V.DamagesReason)
	ELSE '' END) [DamagesReason],
	ISNULL(V.UOMQty, 0) / ISNULL(ReportingUOM, 1) [Received Quantity],
	V.CreationDate [Received On],
	V.Aging

	from V_ARC_Items_BatchDetails V WITH (NOLOCK) 
	WHERE ISNULL(V.Quantity, 0) > 0
	ORDER BY V.Aging DESC 
END
GO
