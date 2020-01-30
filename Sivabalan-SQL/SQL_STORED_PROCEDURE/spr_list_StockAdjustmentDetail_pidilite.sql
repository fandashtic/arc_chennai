CREATE procedure [dbo].[spr_list_StockAdjustmentDetail_pidilite](@STOCKADJID INT)
AS
CREATE TABLE #temp (
	[SerialNO] [int] NOT NULL ,
	[Product_Code] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Batch_Code] [int] NULL ,
	[Batch_Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Quantity] [decimal](18, 6) NULL ,
	[Rate] [decimal](18, 6) NULL ,
	[ReasonID] [int] NULL ,
	[OldQty] [decimal](18, 6) NULL ,
	[OldValue] [decimal](18, 6) NULL,
	IDField int identity not null,
)
insert into #temp select * from stockadjustment where serialno = @STOCKADJID
SELECT "Item Code" = #temp.Product_Code, 
"Item Code" = #temp.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = #temp.Batch_Number,
"Orig Qty" = ISNULL(SUM(OldQty),0), 
"Orig Value" = ISNULL(SUM(OldValue),0), 
"New Qty" = ISNULL(SUM(#temp.Quantity),0), 
"Reporting UOM" = IsNull(SUM((IsNull(#temp.Quantity, 0)) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End), 0),
"Conversion Factor" = ISNULL(SUM((IsNull(#temp.Quantity, 0)) * IsNull(ConversionFactor, 0)), 0),
"New Value" = ISNULL(SUM(Rate), 0),
"Adj Qty" = ISNULL(SUM(#temp.Quantity),0) - IsNull(Sum(OldQty), 0),
"Adj Value" = ISNULL(SUM(Rate), 0) - ISNULL(SUM(OldValue),0) ,
"Reason" = StockAdjustmentReason.Message
FROM #temp, Items, StockAdjustmentReason
WHERE #temp.SerialNo = @STOCKADJID
AND #temp.Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS = Items.Product_Code
AND #temp.ReasonID *= StockadjustmentReason.MessageID
GROUP BY #temp.Product_Code, Items.ProductName, 
#temp.Batch_Number, StockAdjustmentReason.Message
Order By MAX(#temp.IDField)
drop table #temp
