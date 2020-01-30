CREATE procedure [dbo].[spr_vanStockTransferDetail] @DocSerial int  
as  
select "Product Code" = vantransferDetail.Product_code,  
"Product Name" = items.Productname,"Batch Number" = vantransferdetail.BatchNumber,  
"Expiry" = Batch_Products.Expiry, 
"Sales Price" = vantransferdetail.Saleprice,  
"Transfer Qty" = Sum(vantransferdetail.quantity),
"Transfer Value" = Sum(value) 
from vantransferDetail,  
Items,batch_products where vantransferDetail.Product_Code = items.product_code and   
VantransferDetail.BatchCode *= Batch_products.Batch_Code  
and docserial = @DocSerial  
Group By vantransferDetail.Product_code,items.Productname,vantransferdetail.BatchNumber,
Batch_Products.Expiry,vantransferdetail.Saleprice
