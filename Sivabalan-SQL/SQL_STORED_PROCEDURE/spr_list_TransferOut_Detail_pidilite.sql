CREATE Procedure spr_list_TransferOut_Detail_pidilite (@DocSerial int)
As
Select max(StockTransferOutDetail.Product_Code),
"Item Code" =  max(StockTransferOutDetail.Product_Code),
"Item Name" = max(Items.ProductName), "Batch" = max(StockTransferOutDetail.Batch_Number),
"PKD" = max(Batch_Products.PKD), "Expiry" = max(Batch_Products.Expiry),
"Quantity" =  Sum(StockTransferOutDetail.Quantity), 
"Reporting UOM" = Sum(StockTransferOutDetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Conversion Factor" = Sum(StockTransferOutDetail.Quantity * IsNull(ConversionFactor, 0)), 
"Rate" = max(StockTransferOutDetail.Rate),
"Amount" =  Sum(StockTransferOutDetail.Amount),
"PTS" = max(StockTransferOutDetail.PTS),
"PTR" = max(StockTransferOutDetail.PTR),
"ECP" = max(StockTransferOutDetail.ECP),
"Remarks" = Case 
When max(IsNull(StockTransferOutDetail.Free, 0)) = 0 Then
N''
Else
N'Free'
End
From StockTransferOutDetail, Batch_Products, Items
Where StockTransferOutDetail.DocSerial = @DocSerial And
StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code And
StockTransferOutDetail.Product_Code = Items.Product_Code
Group By StockTransferOutDetail.Serial
Order By StockTransferOutDetail.Serial


