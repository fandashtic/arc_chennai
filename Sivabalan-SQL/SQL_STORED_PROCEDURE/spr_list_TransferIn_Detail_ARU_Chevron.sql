CREATE Procedure spr_list_TransferIn_Detail_ARU_Chevron(@DocSerial int)
As
Select StockTransferInDetail.Product_Code,
"Item Code" = StockTransferInDetail.Product_Code,
"Item Name" = Items.ProductName, "Quantity" = Sum(StockTransferInDetail.Quantity),
"Rate" = StockTransferInDetail.Rate, "Amount" = Sum(StockTransferInDetail.Amount), 
"Batch" = StockTransferInDetail.Batch_Number,
"Expiry" = StockTransferInDetail.Expiry, "PKD" = StockTransferInDetail.PKD, 
"PTS" = StockTransferInDetail.PTS, "PTR" = StockTransferInDetail.PTR,
"ECP" = StockTransferInDetail.ECP
From StockTransferInDetail, Items
Where StockTransferInDetail.DocSerial = @DocSerial And
StockTransferInDetail.Product_Code = Items.Product_Code
Group By StockTransferInDetail.Product_Code, Items.ProductName,
StockTransferInDetail.Batch_Number, StockTransferInDetail.Expiry, StockTransferInDetail.PKD,
StockTransferInDetail.PTS, StockTransferInDetail.PTR, StockTransferInDetail.ECP,
StockTransferInDetail.Rate
