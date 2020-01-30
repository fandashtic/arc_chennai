CREATE PROCEDURE spr_list_expiryitem_detail_pidilite( @ITEMCODE nvarchar(15),
					   @EXPDATE datetime)
AS
SELECT Batch_Number, "Batch" = Batch_Number, "Expiry" = Expiry, "Quantity" = Quantity, 
"Reporting UOM" = Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End,
"Conversion Factor" = Quantity * IsNull(ConversionFactor, 0),
"Value" = (PurchasePrice * Quantity) FROM Items, Batch_products
WHERE Items.Product_Code = Batch_products.Product_Code And Batch_products.Product_Code = @ITEMCODE AND Expiry IS NOT NULL AND Expiry <= @EXPDATE
and Quantity > 0
