CREATE PROCEDURE [dbo].[spr_list_itemsshortexpired]
AS
DECLARE @expmon INT
SELECT @expmon = ISNULL(shortexpirymonths,0) 
FROM setup

SELECT items.product_code,"Item Code"=items.product_code,"Item Name"=items.productname,"Vendor"=vendors.vendor_name,
"Quantity"=sum(batch_products.quantity),"Value"=Sum(batch_products.PurchasePrice * batch_products.Quantity)
FROM batch_products
Inner Join items on items.product_code = batch_products.product_code
Left Outer Join vendors on items.preferred_vendor = vendors.vendorid
WHERE 
--items.product_code = batch_products.product_code 
--and items.preferred_vendor *= vendors.vendorid
--and 
batch_products.expiry IS NOT NULL 
and batch_products.expiry between GETDATE() and DATEADD(mm,@expmon,GETDATE())
and batch_products.quantity>0
GROUP BY
items.product_code, items.productname, vendors.vendor_name
