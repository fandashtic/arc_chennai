CREATE PROCEDURE [dbo].[spr_list_StockAdjustment_Damages](@FROMDATE DATETIME,
@TODATE DATETIME,@UOM nVarchar(30))

AS

Declare @STOCKADJUSMENTDAMAGES As NVarchar(50)
Declare @PHYSICALSTOCKRECONCILATIONDAMAGES  As NVarchar(50)
Set @STOCKADJUSMENTDAMAGES = dbo.LookupDictionaryItem(N'Stock Adjusment - Damages',Default)
Set @PHYSICALSTOCKRECONCILATIONDAMAGES = dbo.LookupDictionaryItem(N'Physical Stock Reconcilation - Damages',Default)

SELECT AdjustmentID As Adjustid, "AdjustmentID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),
AdjustmentDate, "AdjustmentValue" = ISNULL(AdjustmentValue, 0), "User Name" = UserName
,"Adjustment Type" = Case StockAdjustmentAbstract.AdjustmentType When 0 Then @STOCKADJUSMENTDAMAGES When 4 Then @PHYSICALSTOCKRECONCILATIONDAMAGES  End
FROM StockAdjustmentAbstract, VoucherPrefix
WHERE AdjustmentDate BETWEEN @FROMDATE AND @TODATE AND
VoucherPrefix.TranID = 'STOCK ADJUSTMENT' AND
StockAdjustmentAbstract.AdjustmentType in (0,4)
ORDER BY AdjustmentDate, AdjustmentID
