CREATE PROCEDURE spr_list_items_damagestock_pidilite
AS
SELECT Items.Product_Code, "Item Code" = Items.Product_Code, 
"Item Name" = Items.ProductName, 
"Total Damages" = Sum(Quantity), 
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
"Manufacturer" = manufacturer_name
FROM Items, Batch_Products, manufacturer
WHERE 	Items.Product_Code = Batch_Products.Product_Code And IsNull(Damage, 0) > 0 And Quantity > 0
and manufacturer.manufacturerid = items.manufacturerid
Group By Items.Product_Code, Items.ProductName, manufacturer_name
ORDER BY Items.Product_Code


