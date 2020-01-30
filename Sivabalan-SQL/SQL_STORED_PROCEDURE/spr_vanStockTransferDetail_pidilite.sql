CREATE procedure [dbo].[spr_vanStockTransferDetail_pidilite] @DocSerial int
as
select "Product Code" = vantransferDetail.Product_code,
"Product Name" = items.Productname,"Batch Number" = vantransferdetail.BatchNumber,
"Expiry" = Batch_Products.Expiry, "Sales Price" = vantransferdetail.Saleprice,
"Transfer Qty" = vantransferdetail.quantity,
"Reporting UOM" = vantransferdetail.quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End,  
"Conversion Factor" = vantransferdetail.quantity * IsNull(ConversionFactor, 0),  
"Transfer Value" = value from vantransferDetail,
Items,batch_products where vantransferDetail.Product_Code = items.product_code and 
VantransferDetail.BatchCode *= Batch_products.Batch_Code
and docserial = @DocSerial
