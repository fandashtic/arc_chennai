CREATE procedure [dbo].[sp_Print_StockTransferOutDetail_RespectiveUOM_serial](@DocSerial int)      
As      
Select "Item Code" = StockTransferOutDetail.Product_Code,       
"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetail.Batch_Number,       
"PKD" = Batch_Products.PKD, "Expiry" = Batch_Products.Expiry,      
"Rate" = Case StockTransferOutDetail.UOMPrice      
When 0 then      
'Free'      
Else      
Cast(StockTransferOutDetail.UOMPrice as nvarchar)      
End,       
"Quantity" = StockTransferOutDetail.UOMQty,    
"UOM" = UOM.Description,     
"Amount" = Amount,     
"PTS" = Batch_Products.PTS,       
"PTR" = Batch_Products.PTR,    
"ECP" = Batch_Products.ECP,    
"Special Price" = Batch_Products.Company_Price,      
"Tax Suffered" = IsNull(StockTransferOutDetail.TaxSuffered, 0),      
"Tax Amount" = IsNull(StockTransferOutDetail.TaxAmount, 0),      
"Total Amount" = IsNull(StockTransferOutDetail.TotalAmount, 0)      
From StockTransferOutDetail, Items, Batch_Products, UOM  
Where StockTransferOutDetail.Product_Code = Items.Product_Code And      
StockTransferOutDetail.Batch_Code *= Batch_Products.Batch_Code And      
StockTransferOutDetail.DocSerial = @DocSerial  And    
StockTransferOutDetail.UOM *= UOM.UOM  And
StockTransferOutDetail.UOMQty > 0
Order by StockTransferOutDetail.Serial
