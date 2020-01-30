Create Procedure sp_Print_StockTransferOutDetailReceived_MUOM (@DocSerial int)      
As      
Select "Item Code" = StockTransferOutDetailReceived.Product_Code,       
"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetailReceived.Batch_Number,       
"PKD" = StockTransferOutDetailReceived.PKD, "Expiry" = StockTransferOutDetailReceived.Expiry,      
"Rate" = Case Sum(Rate)      
When 0 then      
'Free'      
Else      
Cast(Sum(Rate) as nvarchar)      
End,       
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(StockTransferOutDetailReceived.Product_Code, Sum(StockTransferOutDetailReceived.Quantity)),        
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  StockTransferOutDetailReceived.Product_Code )),        
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(StockTransferOutDetailReceived.Product_Code, Sum(StockTransferOutDetailReceived.Quantity)),        
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  StockTransferOutDetailReceived.Product_Code )),        
"UOMQuantity" = dbo.GetLastLevelUOMQty(StockTransferOutDetailReceived.Product_Code, Sum(StockTransferOutDetailReceived.Quantity)),        
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  StockTransferOutDetailReceived.Product_Code )),        
"Amount" = Sum(Amount),       
"PTS" = Max(StockTransferOutDetailReceived.PTS),      
"PTR" = Max(StockTransferOutDetailReceived.PTR),       
"ECP" = Max(StockTransferOutDetailReceived.ECP),      
"Special Price" = Max(StockTransferOutDetailReceived.SpecialPrice)  ,      
"Tax Suffered" = IsNull(Sum(StockTransferOutDetailReceived.TaxSuffered), 0),      
"Tax Amount" = IsNull(Sum(StockTransferOutDetailReceived.TaxAmount), 0),      
"Total Amount" = IsNull(Sum(StockTransferOutDetailReceived.TotalAmount), 0)      
From StockTransferOutDetailReceived, Items       
Where StockTransferOutDetailReceived.Product_Code = Items.Product_Code And      
StockTransferOutDetailReceived.DocSerial = @DocSerial      
Group By StockTransferOutDetailReceived.Product_Code, Items.ProductName,      
StockTransferOutDetailReceived.Batch_Number, StockTransferOutDetailReceived.Expiry, StockTransferOutDetailReceived.PKD,      
StockTransferOutDetailReceived.SpecialPrice,StockTransferOutDetailReceived.Rate    
Order By StockTransferOutDetailReceived.Product_Code    
