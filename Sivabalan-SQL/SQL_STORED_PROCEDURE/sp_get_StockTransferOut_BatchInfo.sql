CREATE Procedure sp_get_StockTransferOut_BatchInfo (@DocSerial int,    
          @ItemCode nvarchar(20))    
As    
Select StockTransferOutDetail.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD,     
Sum(StockTransferOutDetail.Quantity),     
StockTransferOutDetail.Rate, StockTransferOutDetail.Free,    
StockTransferOutDetail.TaxSuffered,    
StockTransferOutDetail.PTS, StockTransferOutDetail.PTR, StockTransferOutDetail.ECP,    
StockTransferOutDetail.SpecialPrice,StockTransferOutDetail.TaxSuffApplicableOn,    
StockTransferOutDetail.TaxSuffPartOff 
,StockTransferOutDetail.MRPPerPack,StockTransferOutDetail.TaxType
,StockTransferOutDetail.MRPforTax,Isnull(StockTransferOutDetail.TOQ,0) TOQ,Isnull(StockTransferOutDetail.TaxID,0) TaxID
From StockTransferOutDetail, Batch_Products    
Where StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code And    
StockTransferOutDetail.Product_Code = @ItemCode And    
StockTransferOutDetail.DocSerial = @DocSerial    
Group By StockTransferOutDetail.Product_Code, StockTransferOutDetail.Batch_Number,    
StockTransferOutDetail.PTS, StockTransferOutDetail.PTR, StockTransferOutDetail.ECP,    
StockTransferOutDetail.SpecialPrice, StockTransferOutDetail.Free, Batch_Products.PKD,    
Batch_Products.Expiry, StockTransferOutDetail.TaxSuffered,StockTransferOutDetail.Rate,    
StockTransferOutDetail.TaxSuffApplicableOn,StockTransferOutDetail.TaxSuffPartOff 
,StockTransferOutDetail.MRPPerPack,StockTransferOutDetail.TaxType
,StockTransferOutDetail.MRPforTax,Isnull(StockTransferOutDetail.TOQ,0)  
,isnull(StockTransferOutDetail.TaxID,0)
