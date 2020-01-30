CREATE Procedure sp_view_StockTransferOutDetail (@DocSerial int)  
As  
Select StockTransferOutDetail.Product_Code, Items.ProductName,   
--StockTransferOutDetail.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry,  
Null, Null, Null,  
Max(Rate), Sum(StockTransferOutDetail.Quantity), Sum(Amount),  
Max(StockTransferOutDetail.TaxSuffered), Sum(StockTransferOutDetail.TaxAmount),   
Sum(StockTransferOutDetail.TotalAmount),  
Max(StockTransferOutDetail.Serial) "Serial", Max(StockTransferOutDetail.SchemeID) "SchemeID", Max(StockTransferOutDetail.FreeSerial) "FreeSerial" , Max(StockTransferOutDetail.SchemeFree) "SchemeFree",
StockTransferOutDetail.TaxSuffApplicableOn,StockTransferOutDetail.TaxSuffPartOff,  
StockTransferOutDetail.VAT         
From StockTransferOutDetail, Items  
Where StockTransferOutDetail.Product_Code = Items.Product_Code And  
StockTransferOutDetail.DocSerial = @DocSerial  
Group By StockTransferOutDetail.Product_Code, Items.ProductName,  
StockTransferOutDetail.TaxSuffApplicableOn,StockTransferOutDetail.TaxSuffPartOff,  
StockTransferOutDetail.VAT        



