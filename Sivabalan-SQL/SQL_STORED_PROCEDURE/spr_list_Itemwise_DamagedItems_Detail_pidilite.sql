CREATE Procedure spr_list_Itemwise_DamagedItems_Detail_pidilite (@ItemCode nVarchar(20),
							@FromDate datetime,
							@ToDate datetime)
As
Select Items.Product_Code, "Item Name" = Items.ProductName,
"Sales Return Damages" = IsNull((Select Sum(Quantity) From InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
(InvoiceAbstract.Status & 32) <> 0 And
InvoiceDetail.Product_Code = @ItemCode And
InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate), 0),
"Sales Return Damages Reporting UOM" = IsNull((Select Sum(Quantity / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 0) End)
From Items, InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
(InvoiceAbstract.Status & 32) <> 0 And
InvoiceDetail.Product_Code = Items.Product_Code And 
Items.Product_Code = @ItemCode And
InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate), 0),
"Sales Return Damages Conversion Factor" = IsNull((Select Sum(Quantity * IsNull(Items.ConversionFactor, 0)) 
From Items, InvoiceAbstract, InvoiceDetail
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
(InvoiceAbstract.Status & 32) <> 0 And
InvoiceDetail.Product_Code = Items.Product_Code And 
Items.Product_Code = @ItemCode And
InvoiceAbstract.InvoiceType = 4 And
InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate), 0),
"Stock Adjustment Damages" = IsNull((Select Sum(Quantity)
From StockAdjustmentAbstract, StockAdjustment 
Where StockAdjustmentAbstract.AdjustmentID = StockAdjustment.SerialNo And
StockAdjustmentAbstract.AdjustmentType = 0 And
StockAdjustment.Product_Code = @ItemCode And
StockAdjustmentAbstract.AdjustmentDate Between @FromDate And @ToDate), 0),
"Stock Adjustment Damages Reporting UOM" = IsNull((Select Sum(Quantity / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 0) End)
From Items, StockAdjustmentAbstract, StockAdjustment 
Where StockAdjustmentAbstract.AdjustmentID = StockAdjustment.SerialNo And
StockAdjustmentAbstract.AdjustmentType = 0 And
StockAdjustment.Product_Code = Items.Product_Code And
Items.Product_Code = @ItemCode And
StockAdjustmentAbstract.AdjustmentDate Between @FromDate And @ToDate), 0),
"Stock Adjustment Damages Conversion Factor" = IsNull((Select Sum(Quantity * IsNull(Items.ConversionFactor, 0))
From Items, StockAdjustmentAbstract, StockAdjustment 
Where StockAdjustmentAbstract.AdjustmentID = StockAdjustment.SerialNo And
StockAdjustmentAbstract.AdjustmentType = 0 And
StockAdjustment.Product_Code = Items.Product_Code And 
Items.Product_Code = @ItemCode And
StockAdjustmentAbstract.AdjustmentDate Between @FromDate And @ToDate), 0)
From Items
Where Items.Product_Code = @ItemCode
