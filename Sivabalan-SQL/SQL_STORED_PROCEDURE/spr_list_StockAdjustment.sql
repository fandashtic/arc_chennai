CREATE PROCEDURE [dbo].[spr_list_StockAdjustment](@FROMDATE DATETIME,
@TODATE DATETIME,@UOM nVarchar(50))

AS
Declare @STOCKADJUSMENTOTHERS As NVarchar(50)
Declare @PHYSICALSTOCKRECONCILATIONSALEABLE  As NVarchar(50)

Set @STOCKADJUSMENTOTHERS = dbo.LookupDictionaryItem(N'Stock Adjusment - Others',Default)
Set @PHYSICALSTOCKRECONCILATIONSALEABLE = dbo.LookupDictionaryItem(N'Physical Stock Reconcilation - Saleable',Default)

SELECT Cast(AdjustmentID As nVarchar(50)) As AdjID, "AdjustmentID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),
AdjustmentDate, "AdjustmentValue" = ISNULL(AdjustmentValue, 0), "User Name" = UserName
,"Adjustment Type" = Case StockAdjustmentAbstract.AdjustmentType When 1 Then @STOCKADJUSMENTOTHERS When 3 Then @PHYSICALSTOCKRECONCILATIONSALEABLE End
FROM StockAdjustmentAbstract, VoucherPrefix
WHERE AdjustmentDate BETWEEN @FROMDATE AND @TODATE AND
VoucherPrefix.TranID = 'STOCK ADJUSTMENT' AND
StockAdjustmentAbstract.AdjustmentType in (1,3)
ORDER BY AdjustmentDate, AdjustmentID
