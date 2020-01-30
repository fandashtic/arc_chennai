CREATE procedure [dbo].[sp_print_DispatchItems_FMCG_RespectiveUOM] (@DISPATCHID INT)  
AS  
SELECT "Item Code" = DispatchDetail.Product_Code, "Item Name" = Items.ProductName,   
"Quantity" = DispatchDetail.UOMQty,   
"UOM" = UOM.Description,
"Batch" = Batch_Products.Batch_Number,   
"Sale Price" = DispatchDetail.UOMPrice,  
"Amount" = DispatchDetail.Quantity * DispatchDetail.SalePrice,  
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
DispatchDetail.Quantity * DispatchDetail.SalePrice * (IsNull(Tax.Percentage,0)/100)
ELSE
DispatchDetail.Quantity * DispatchDetail.SalePrice * (IsNull(Tax.CST_Percentage,0)/100)
END As Decimal(18,6)),
"Category" = ItemCategories.Category_Name,
"Purchase Price" = CASE ItemCategories.Price_Option
WHEN 1 THEN
Batch_Products.PurchasePrice
ELSE
Items.Purchase_Price
END
FROM DispatchDetail, DispatchAbstract, Tax, Customer, Items, Batch_Products, 
UOM, Manufacturer, Brand, ConversionTable, ItemCategories  
WHERE DispatchDetail.DispatchID = DispatchAbstract.DispatchID And
DispatchAbstract.DispatchID = @DISPATCHID And
Customer.CustomerID = DispatchAbstract.CustomerID And
Items.Sale_Tax *=  Tax.Tax_Code
AND DispatchDetail.Product_Code = Items.Product_Code  
AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code  
AND ItemCategories.CategoryID = Items.CategoryID
AND DispatchDetail.UOM *= UOM.UOM   
And Items.BrandID = Brand.BrandID  
And Items.ManufacturerID = Manufacturer.ManufacturerID  
And Items.ConversionUnit *= ConversionTable.ConversionID  
order by dispatchdetail.serial
