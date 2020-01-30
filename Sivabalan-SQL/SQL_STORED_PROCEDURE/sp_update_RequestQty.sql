CREATE Procedure sp_update_RequestQty as
Begin Tran
Update items set PendingRequest = isnull(StockNorm, 0)

update items set PendingRequest = PendingRequest - 
isnull((select sum(Batch_Products.Quantity) from batch_products 
where Batch_products.Product_Code = Items.Product_Code 
and (Batch_products.Expiry >= Getdate() OR Batch_Products.Expiry IS NULL)),0) 
where ISNULL(StockNorm,0) <> 0

update items set PendingRequest = PendingRequest - 
isnull((select sum(PODetail.Pending) from PODetail, POAbstract
where PODetail.Product_Code = Items.Product_Code AND 
POAbstract.PONumber = PODetail.PONumber AND 
(POAbstract.Status & 128) = 0),0) where ISNULL(StockNorm,0) <> 0

update items set PendingRequest = PendingRequest - 
isnull((select sum(stock_request_detail.Pending) 
from stock_request_detail, stock_request_abstract
where stock_request_detail.Product_Code = Items.Product_Code 
AND stock_request_abstract.Stock_Req_Number = stock_request_detail.Stock_Req_Number
AND (stock_request_abstract.Status & 128) = 0),0) where ISNULL(StockNorm,0) <> 0

update items set PendingRequest = PendingRequest - (Cast(PendingRequest As Int) % Cast(MinOrderQty As Int)) 
where Isnull(MinOrderQty, 0) <> 0
Commit Tran 
