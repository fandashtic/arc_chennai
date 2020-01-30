CREATE procedure [dbo].[sp_list_StockTransferOutDetail_Amend] (@DocSerial int)    
As    
Select max(StockTransferOutDetail.Product_Code),max(Items.ProductName),     
max(StockTransferOutDetail.Batch_Number),max(Batch_Products.PKD),max(Batch_Products.Expiry),    
Rate, Sum(StockTransferOutDetail.Quantity), Sum(Amount),    
max(StockTransferOutDetail.TaxSuffered), Sum(StockTransferOutDetail.TaxAmount),     
Sum(StockTransferOutDetail.TotalAmount),max(ItemCategories.Track_Inventory),    
max(ItemCategories.Price_Option),max(Items.Virtual_Track_Batches),    
Case Rate    
When 0 Then    
1    
Else    
0    
End,    
max(Items.TrackPKD),max(StockTransferOutDetail.PTS),max(StockTransferOutDetail.PTR),     
max(StockTransferOutDetail.ECP),max(StockTransferOutDetail.SpecialPrice), 
StockTransferOutDetail.Serial "Serial", max(StockTransferOutDetail.SchemeID) "SchemeID", max(StockTransferOutDetail.FreeSerial) "FreeSerial" , max(StockTransferOutDetail.SchemeFree) "SchemeFree",
max(StockTransferOutDetail.TaxSuffApplicableOn)"TaxSuffApplicableOn",max(StockTransferOutDetail.TaxSuffPartOff) "TaxSuffPartOff",  
max(StockTransferOutDetail.VAT) "VAT"         
From StockTransferOutDetail, Items, ItemCategories, Batch_Products    
Where StockTransferOutDetail.Product_Code = Items.Product_Code And    
StockTransferOutDetail.DocSerial = @DocSerial And    
Items.CategoryID = ItemCategories.CategoryID And    
StockTransferOutDetail.Batch_Code *= Batch_Products.Batch_Code    
Group By StockTransferOutDetail.Serial,StockTransferOutDetail.Rate
Order By StockTransferOutDetail.Serial
