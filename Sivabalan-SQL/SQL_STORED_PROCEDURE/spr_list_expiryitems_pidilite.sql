CREATE PROCEDURE [dbo].[spr_list_expiryitems_pidilite](@EXPDATE datetime)  
AS  
SELECT Items.Product_Code,"Item Code"=Items.Product_Code, "Item Name" = Items.ProductName,   
"Manufacturer" = Manufacturer.Manufacturer_Name,
"Vendor" = Vendors.Vendor_Name, "Quantity" = Sum(Quantity),
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
"Value" = Sum(PurchasePrice * Quantity) FROM Items
Inner Join Batch_Products On Items.Product_Code = Batch_Products.Product_Code
Left Outer Join Vendors On Items.Preferred_Vendor = Vendors.VendorID
Left Outer Join Manufacturer  On Manufacturer.ManufacturerID = Items.ManufacturerID
WHERE 
Batch_Products.Expiry IS NOT NULL AND  
Batch_Products.Expiry <= @EXPDATE AND  
Batch_Products.Quantity > 0  
GROUP BY Items.Product_Code, Items.ProductName, Vendors.Vendor_Name, Manufacturer.Manufacturer_Name 


