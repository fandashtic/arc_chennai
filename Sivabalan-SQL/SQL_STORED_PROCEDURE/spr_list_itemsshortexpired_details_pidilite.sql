CREATE PROCEDURE spr_list_itemsshortexpired_details_pidilite( @ITEMCODE nvarchar(15))  
AS  
DECLARE @expmon INT  
SELECT @expmon = ISNULL(shortexpirymonths,0)   
FROM setup  
SELECT "BatchNumber"=Batch_Number, "Expiry"=Expiry,"PKD"= pkd,  
"Quantity" = SUM(quantity),  
"Reporting UOM" = SUM(quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),    
"Conversion Factor" = sum(Quantity * IsNull(ConversionFactor, 0)),    
"PTS" = Batch_products.pts,"PTR" = Batch_products.ptr,   
"ECP" = Batch_products.ecp, "Special Price" = Batch_products.company_price  
FROM Batch_products, Items  
WHERE Batch_products.Product_Code =  Items.Product_Code And  
Items.Product_Code = @ITEMCODE   
and Quantity > 0    
and expiry IS NOT NULL   
and expiry between GETDATE() and DATEADD(mm,@expmon,GETDATE())  
GROUP BY batch_number, expiry, Batch_products.pkd, Batch_products.pts,   
Batch_products.ptr, Batch_products.ecp, Batch_products.company_price  

