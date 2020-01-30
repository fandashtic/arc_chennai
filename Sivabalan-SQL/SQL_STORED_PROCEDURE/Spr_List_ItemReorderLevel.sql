CREATE Procedure Spr_List_ItemReorderLevel  
as  
Select   
Product_Code ,"Item Code" = Product_Code ,"Item Name" = ProductName , "UOM" = [Sales UOM] ,   
"Stock Norm" = StockNorm ,"Closing Stock" = [Closing Stock] , "Purchase Price" = Purchase_Price ,  
"Excess Qty" =
Case  
When [Closing Stock] - StockNorm > 0   
then [Closing Stock] - StockNorm  
Else Null End,  
"Reorder Qty" = Case  
When StockNorm - [Closing Stock] > 0   
then StockNorm - [Closing Stock]  
Else Null End ,  
"Value" = Case  
When StockNorm - [Closing Stock] > 0   
then (StockNorm - [Closing Stock]) * Purchase_Price   
Else Null End
from  
(Select Items.Product_Code,  
Items.ProductName , "Sales UOM" = UOM.Description , Items.StockNorm ,  
isnull((select sum(Batch_Products.Quantity) from batch_products     
where Batch_products.Product_Code = Items.Product_Code     
and (Batch_products.Expiry >= Getdate() OR Batch_Products.Expiry IS NULL)),0)  
+   
isnull((select sum(PODetail.Pending) from PODetail, POAbstract    
where PODetail.Product_Code = Items.Product_Code AND     
POAbstract.PONumber = PODetail.PONumber AND     
(POAbstract.Status & 128) = 0),0)  
+  
isnull((Select Sum(Stock_Request_Detail.Pending)     
From Stock_Request_Detail, Stock_Request_Abstract    
Where Stock_Request_Detail.Product_Code = Items.Product_Code And    
Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number And    
(Stock_Request_Abstract.Status & 128) = 0),0) as "Closing Stock" ,  
Items.Purchase_Price  
From Items , UOM   
Where Items.UOM = UOM.UOM) TempRecord  
  


