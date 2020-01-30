CREATE Procedure sp_Print_StockTransferInDetail_RespectiveUOM (@DocSerial int)  
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
"Rate" = StockTransferInDetail.UOMPrice,   
"Quantity" = StockTransferInDetail.UOMQty,   
"UOM" = UOM.Description,  
"Amount" = StockTransferInDetail.Amount,   
"Expiry" = StockTransferInDetail.Expiry,   
"PKD" = StockTransferInDetail.PKD,  
"Tax Suffered" = StockTransferInDetail.TaxSuffered,  
"Tax Amount" = StockTransferInDetail.TaxAmount,  
"Total Amount" = StockTransferInDetail.TotalAmount,
"PFM" = StockTransferInDetail.PFM
From StockTransferInDetail
Inner Join Items On StockTransferInDetail.Product_Code = Items.Product_Code
Left Outer Join UOM On StockTransferInDetail.UOM = UOM.UOM
Inner Join ItemCategories  On ItemCategories.CategoryID = Items.CategoryID  
Where StockTransferInDetail.DocSerial = @DocSerial 
Order by StockTransferInDetail.Product_Code  
  
