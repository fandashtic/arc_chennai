CREATE Procedure sp_update_OrderQty as  
Begin Tran  
Update items set OrderQty = isnull(StockNorm, 0)  
  
update items set OrderQty = OrderQty -   
isnull((select sum(Batch_Products.Quantity) from batch_products   
where Batch_products.Product_Code = Items.Product_Code   
and (Batch_products.Expiry >= Getdate() OR Batch_Products.Expiry IS NULL)),0)   
where ISNULL(StockNorm,0) <> 0  
  
update items set OrderQty = OrderQty -   
isnull((select sum(PODetail.Pending) from PODetail, POAbstract  
where PODetail.Product_Code = Items.Product_Code AND   
POAbstract.PONumber = PODetail.PONumber AND   
(POAbstract.Status & 128) = 0),0) where ISNULL(StockNorm,0) <> 0 
  
Update Items Set OrderQty = OrderQty -   
IsNull((Select Sum(Stock_Request_Detail.Pending)   
From Stock_Request_Detail, Stock_Request_Abstract  
Where Stock_Request_Detail.Product_Code = Items.Product_Code And  
Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number And  
(Stock_Request_Abstract.Status & 128) = 0), 0) Where IsNull(StockNorm, 0) <> 0  
  
update items set OrderQty =  cast(OrderQty as int) - (cast(OrderQty as int) % cast(MinOrderQty as int))   
where Isnull(MinOrderQty, 0) <> 0

Commit Tran





