CREATE Procedure sp_Print_StockTransferInDetail (@DocSerial int)
As
Select "Item Code" = StockTransferInDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = Batch_Number, 
"PTS" = CASE Price_Option 
WHEN 1 THEN
StockTransferInDetail.PTS
ELSE
Items.PTS
END, 
"PTR" = CASE Price_Option
WHEN 1 THEN
 StockTransferInDetail.PTR
ELSE
Items.PTR
END,   
"ECP" = CASE Price_Option
WHEN 1 THEN
StockTransferInDetail.ECP
ELSE
Items.ECP
END,
"Special Price" = CASE Price_Option
WHEN 1 THEN
StockTransferInDetail.SpecialPrice
ELSE
Items.Company_Price
END,
"DocQty" = StockTransferInDetail.DocumentQuantity,
"DocFreeQty"=StockTransferInDetail.DocumentFreeQty,
"Received Qty" = StockTransferInDetail.QuantityReceived,
"Rejected Qty" = StockTransferInDetail.QuantityRejected, 
"Rate" = StockTransferInDetail.Rate, 
"Quantity" = StockTransferInDetail.Quantity, 
"Amount" = StockTransferInDetail.Amount, 
"Expiry" = StockTransferInDetail.Expiry, 
"PKD" = StockTransferInDetail.PKD,
"Tax Suffered" = StockTransferInDetail.TaxSuffered,
"Tax Amount" = StockTransferInDetail.TaxAmount,
"Total Amount" = StockTransferInDetail.TotalAmount
From StockTransferInDetail, Items, ItemCategories
Where StockTransferInDetail.DocSerial = @DocSerial And
StockTransferInDetail.Product_Code = Items.Product_Code And
ItemCategories.CategoryID = Items.CategoryID
order by StockTransferInDetail.Product_Code


