CREATE procedure [dbo].[spr_list_itemsshortexpired_pidilite]  
AS  
DECLARE @expmon INT  
SELECT @expmon = ISNULL(shortexpirymonths,0)   
FROM setup  
  
SELECT items.product_code,"Item Code"=items.product_code,"Item Name"=items.productname,"Vendor"=vendors.vendor_name,  
"Quantity"=sum(batch_products.quantity),  
"Reporting UOM" = sum(batch_products.quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),    
"Conversion Factor" = sum(batch_products.quantity * IsNull(ConversionFactor, 0)),    
"Value"=Sum(batch_products.PurchasePrice * batch_products.Quantity)  
FROM batch_products,items,vendors   
WHERE   
items.product_code = batch_products.product_code   
and items.preferred_vendor *= vendors.vendorid  
and batch_products.expiry IS NOT NULL   
and batch_products.expiry between GETDATE() and DATEADD(mm,@expmon,GETDATE())  
GROUP BY  
items.product_code, items.productname, vendors.vendor_name
