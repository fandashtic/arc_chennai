CREATE procedure [dbo].[sp_Print_StockTransferOutDetail_Serial] (@DocSerial int)      
As      

Declare @FREE As NVarchar(50)

Set @FREE = dbo.LookupDictionaryItem(N'Free', Default)

Select "Item Code" = StockTransferOutDetail.Product_Code,       
"Item Name" = Items.ProductName, "Batch" = StockTransferOutDetail.Batch_Number,       
"PKD" = Batch_Products.PKD, "Expiry" = Batch_Products.Expiry,      
"Rate" = Case Sum(Rate)      
When 0 then      
@FREE
Else      
Cast(Max(Rate) as nvarchar)      
End, "Quantity" = Sum(StockTransferOutDetail.Quantity),       
"Amount" = Sum(Amount),     
"PTS" = Max(Batch_Products.PTS),    
"PTR" = Max(Batch_Products.PTR),    
"ECP" = Max(Batch_Products.ECP),    
"Special Price" = Max(Batch_Products.Company_Price),    
"Tax Suffered" = IsNull(Max(StockTransferOutDetail.TaxSuffered), 0),      
"Tax Amount" = IsNull(Sum(StockTransferOutDetail.TaxAmount), 0),      
"Total Amount" = IsNull(Sum(StockTransferOutDetail.TotalAmount), 0)      
From StockTransferOutDetail, Items, Batch_Products      
Where StockTransferOutDetail.Product_Code = Items.Product_Code And      
StockTransferOutDetail.Batch_Code *= Batch_Products.Batch_Code And      
StockTransferOutDetail.DocSerial = @DocSerial      
Group By StockTransferOutDetail.serial,StockTransferOutDetail.Product_Code, Items.ProductName,      
StockTransferOutDetail.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,      
Batch_Products.Company_Price,  StockTransferOutDetail.Rate
