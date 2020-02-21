--exec SP_ARC_StockReconcileDetails '2019-04-01 00:00:00','2020-02-04 23:59:59'
Exec ARC_Insert_ReportData 560, 'Stock Reconcile Details', 1, 'SP_ARC_StockReconcileDetails', 'Click to view Stock Reconcile Details', 417, 1, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_StockReconcileDetails')
BEGIN
    DROP PROC SP_ARC_StockReconcileDetails
END
GO
CREATE PROCEDURE [dbo].SP_ARC_StockReconcileDetails(@FromDate DateTime, @ToDate DateTime)
AS
BEGIN
	SET DATEFORMAT DMY
	select Distinct  A.DocID,
	A.DocumentReference, A.ReconcileDate, A.CreationDate, D.Product_Code, 
	I.ProductName, I.ItemFamily, I.CategoryGroup, I.Category, I.ItemSubFamily,
	D.PhysicalQuantity, D.ActualQuantity,
	(select Max(PTS) from Batch_Products where Batch_Code in (SELECT * from dbo.fn_SplitIn2Rows_Int(D.Batch_code,','))) PTS,
	D.Difference, D.Batch_code,
	dbo.LookupDictionaryItem((Case DamageStock When 1 Then N'Damage' ELse N'Saleable' End), Default) [Reconcile Type],
	dbo.LookupDictionaryItem((Case IsNull(StockStatus,0) When 1 Then N'All' When 1 Then N'With Stock' Else N'Without Stock' End), Default) [Stock Selection],
	"UOM" = (Case A.UOM When 1 Then 'UOM2' When 2 Then 'UOM1' ELse 'BASE UOM' End),
	"Status" = (Case When ISNULL(D.Difference, 0) < 0 THEN 'Shortage' When ISNULL(D.Difference, 0) > 0 THEN 'Excess' Else 'Equal' END)
	--,A.Status
	INTO #Temp
	from ReconcileAbstract A WITH (NOLOCK)
	JOIN ReconcileDetail D WITH (NOLOCK) ON D.ReconcileID = A.ReconcileID
	JOIN V_ARC_Items I WITH (NOLOCK) ON I.Product_Code = D.Product_Code
	--Full OUTER JOIN tbl_merp_ReconcileBatchReason R ON R.ReconcileID = A.ReconcileID
	Where ISNULL(A.Status, 0) = 4
	And dbo.StripDateFromTime(A.ReconcileDate) BETWEEN @FromDate AND @Todate
	Order By 1 ASC

	SELECT 
	DocID,
	DocumentReference,
	ReconcileDate,
	CreationDate,
	[Reconcile Type],
	[Stock Selection],
	UOM,
	Product_Code,
	ProductName,
	ItemFamily,
	CategoryGroup, Category, ItemSubFamily,
	Batch_code [Batch Details],
	PhysicalQuantity,
	ActualQuantity,
	PTS,
	Difference,
	ISNULL(PTS, 0) * ISNULL(Difference, 0) [Adjustment Value],
	[Status]
	FROM #Temp WITH (NOLOCK)

END
GO
