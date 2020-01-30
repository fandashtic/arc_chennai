CREATE procedure [dbo].[sp_print_vanStockTransferDetail_Ascending] (@DocSerial int)
as
select "Product Code" = vantransferDetail.Product_code,
"Product Name" = items.Productname,"Batch Number" = vantransferdetail.BatchNumber,
"Expiry" = Batch_Products.Expiry, "Sale Price" = vantransferdetail.Saleprice,
"Transfer Qty" = vantransferdetail.quantity,"Transfer Value" = value from vantransferDetail,
Items,batch_products where vantransferDetail.Product_Code = items.product_code and 
VantransferDetail.BatchCode *= Batch_products.Batch_Code
and docserial = @DocSerial order by  vantransferDetail.Product_code
