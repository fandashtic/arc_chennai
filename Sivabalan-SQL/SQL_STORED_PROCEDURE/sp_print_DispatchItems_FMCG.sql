CREATE PROCEDURE [dbo].[sp_print_DispatchItems_FMCG](@DISPATCHID INT)
AS
SELECT "Item Code" = DispatchDetail.Product_Code, "Item Name" = Items.ProductName, 
"Quantity" = Sum(DispatchDetail.Quantity), "Batch" = Batch_Products.Batch_Number, 
"UOM" = UOM.Description, "Sale Price" = DispatchDetail.SalePrice,
"Amount" = Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice),
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + '\'  
+ CAST(DATEPART(yyyy, Batch_Products.Expiry) AS nvarchar),  
"Division" = Brand.BrandName, "Manufacturer Name" = Manufacturer.Manufacturer_Name,
"Manufacturer Code" = Manufacturer.ManufacturerCode,
"Description" = Items.Description, 
"Conversion Unit" = ConversionTable.ConversionUnit,
"Conversion Factor" = Items.ConversionFactor,
"Sales Tax (%)" = Cast(Case Customer.Locality
WHEN 1 THEN
IsNull(Tax.Percentage,0)
ELSE
IsNull(Tax.CST_Percentage,0)
END As Decimal(18,6)),
"Sales Tax Value" = Cast(Case Customer.Locality 
WHEN 1 THEN
Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice) * (IsNull(Tax.Percentage,0)/100)
ELSE
Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice) * (IsNull(Tax.CST_Percentage,0)/100)
END As Decimal(18,6)),
"Category" = ItemCategories.Category_Name,
"Purchase Price" = CASE ItemCategories.Price_Option
WHEN 1 THEN
Max(Batch_Products.PurchasePrice)
ELSE
Max(Items.Purchase_Price)
END
FROM DispatchDetail
Inner Join DispatchAbstract on DispatchDetail.DispatchID = DispatchAbstract.DispatchID
Right Join Customer on Customer.CustomerID = DispatchAbstract.CustomerID
Inner Join Items on DispatchDetail.Product_Code = Items.Product_Code
Left Outer Join Tax on Items.Sale_Tax = Tax.Tax_Code
Left Outer Join Batch_Products on DispatchDetail.Batch_Code = Batch_Products.Batch_Code
Inner Join ItemCategories on ItemCategories.CategoryID = Items.CategoryID
Left Outer Join UOM on Items.UOM = UOM.UOM
Inner Join Brand on Items.BrandID = Brand.BrandID
Inner Join Manufacturer on Items.ManufacturerID = Manufacturer.ManufacturerID
Left Outer Join ConversionTable on Items.ConversionUnit = ConversionTable.ConversionID
WHERE 
--DispatchDetail.DispatchID = DispatchAbstract.DispatchID
--And 
DispatchAbstract.DispatchID = @DISPATCHID
--And Customer.CustomerID =* DispatchAbstract.CustomerID 
--And Items.Sale_Tax *= Tax.Tax_Code 
--AND DispatchDetail.Product_Code = Items.Product_Code
--AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code
--AND ItemCategories.CategoryID = Items.CategoryID
--AND Items.UOM *= UOM.UOM 
--And Items.BrandID = Brand.BrandID
--And Items.ManufacturerID = Manufacturer.ManufacturerID
--And Items.ConversionUnit *= ConversionTable.ConversionID
GROUP BY DispatchDetail.Product_Code, Items.ProductName,Batch_Products.Batch_Number,
UOM.Description,DispatchDetail.SalePrice, 
CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + '\'  
+ CAST(DATEPART(yyyy, Batch_Products.Expiry) AS nvarchar),  Brand.BrandName, 
Manufacturer.Manufacturer_Name, Manufacturer.ManufacturerCode, Items.Description,
ConversionTable.ConversionUnit, Items.ConversionFactor, Customer.Locality, Tax.Percentage, 
Tax.CST_Percentage, ItemCategories.Category_Name, ItemCategories.Price_Option
