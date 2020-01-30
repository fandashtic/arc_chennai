CREATE PROCEDURE [dbo].[sp_print_DispatchItems_Serial](@DISPATCHID INT)
AS
SELECT "Item Code" = Max(DispatchDetail.Product_Code), "Item Name" = Max(Items.ProductName), 
"Quantity" = Sum(DispatchDetail.Quantity), "Batch" = Max(Batch_Products.Batch_Number), 
"UOM" = Max(UOM.Description), "Sale Price" = Max(DispatchDetail.SalePrice),
"Amount" = Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice),
"Expiry" = CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS NVARCHAR) + '\'  
+ CAST(DATEPART(yyyy, Max(Batch_Products.Expiry)) AS NVARCHAR),  
"Division" = Max(Brand.BrandName), "Manufacturer Name" = Max(Manufacturer.Manufacturer_Name),
"Manufacturer Code" = Max(Manufacturer.ManufacturerCode),
"Description" = Max(Items.Description), 
"Conversion Unit" = Max(ConversionTable.ConversionUnit),
"Conversion Factor" = Max(Items.ConversionFactor),
"Sales Tax (%)" = Cast(Case Max(Customer.Locality)
WHEN 1 THEN
Max(IsNull(Tax.Percentage,0))
ELSE
Max(IsNull(Tax.CST_Percentage,0))
END As Decimal(18,6)),
"Sales Tax Value" = Cast(Case Max(Customer.Locality) 
WHEN 1 THEN
Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice) * (Max(IsNull(Tax.Percentage,0))/100)
ELSE
Sum(DispatchDetail.Quantity * DispatchDetail.SalePrice) * (Max(IsNull(Tax.CST_Percentage,0))/100)
END As Decimal(18,6)),
"Category" = Max(ItemCategories.Category_Name), 
"PTS" = CASE Max(ItemCategories.Price_Option) 
WHEN 1 THEN
Max(Batch_Products.PTS)
ELSE
Max(Items.PTS) 
END,
"PTR" = CASE Max(ItemCategories.Price_Option)
WHEN 1 THEN
Max(Batch_Products.PTR)
ELSE
Max(Items.PTR) 
END,
"ECP" = CASE Max(ItemCategories.Price_Option)
WHEN 1 THEN
Max(Batch_Products.ECP)
ELSE
Max(Items.ECP)
END
FROM DispatchDetail
Inner Join DispatchAbstract On  DispatchDetail.DispatchID = DispatchAbstract.DispatchID
Left Outer Join  Customer On Customer.CustomerID = DispatchAbstract.CustomerID 
Inner Join Items On DispatchDetail.Product_Code = Items.Product_Code
Left Outer Join Tax On Items.Sale_Tax = Tax.Tax_Code 
Left Outer Join Batch_Products On DispatchDetail.Batch_Code = Batch_Products.Batch_Code
Left Outer Join UOM On Items.UOM = UOM.UOM 
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join Brand On Items.BrandID = Brand.BrandID
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID
WHERE DispatchAbstract.DispatchID = @DISPATCHID
GROUP BY 
	Dispatchdetail.serial
Order By
	Dispatchdetail.serial

