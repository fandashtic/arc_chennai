CREATE procedure [dbo].[sp_print_DispatchItems_FMCG_MultiUOM_Serial] (@DISPATCHID INT)    
AS    

SELECT "Item Code" = DispatchDetail.Product_Code, "Item Name" = Items.ProductName,     
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(DispatchDetail.Product_Code, Sum(DispatchDetail.Quantity)),
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  DispatchDetail.Product_Code )),
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(DispatchDetail.Product_Code, Sum(DispatchDetail.Quantity)),
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  DispatchDetail.Product_Code )),
"UOMQuantity" = dbo.GetLastLevelUOMQty(DispatchDetail.Product_Code, Sum(DispatchDetail.Quantity)),
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  DispatchDetail.Product_Code )),
"Batch" = Batch_Products.Batch_Number,     
"Sale Price" = DispatchDetail.SalePrice,    
"Amount" = Sum(DispatchDetail.Quantity) * DispatchDetail.SalePrice,    
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + '\'  
+ CAST(DATEPART(yyyy, Batch_Products.Expiry) AS nvarchar),  
"Division" = Brand.BrandName, "Manufacturer Name" = Manufacturer.Manufacturer_Name,    
"Manufacturer Code" = Manufacturer.ManufacturerCode,
"Description" = Items.Description,     
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Conversion Factor" = Items.ConversionFactor,
"Sales Tax (%)" = Cast(Case Customer.Locality 
WHEN 1 THEN
IsNull(Sum(Tax.Percentage),0)
ELSE
IsNull(Sum(Tax.CST_Percentage),0)
END As Decimal(18,6)),
"Sales Tax Value" = Cast(Case Customer.Locality 
WHEN 1 THEN
Sum(DispatchDetail.Quantity) * DispatchDetail.SalePrice * (IsNull(Sum(Tax.Percentage),0)/100)
ELSE
Sum(DispatchDetail.Quantity) * DispatchDetail.SalePrice * (IsNull(Sum(Tax.CST_Percentage),0)/100)
END As Decimal(18,6)),
"Category" = ItemCategories.Category_Name,
"Purchase Price" = CASE ItemCategories.Price_Option
WHEN 1 THEN
Max(Batch_Products.PurchasePrice)
ELSE
Max(Items.Purchase_Price)
END
FROM DispatchAbstract, Tax, Customer, DispatchDetail, Items, Batch_Products, UOM, 
Manufacturer, Brand, ConversionTable, ItemCategories
WHERE DispatchDetail.DispatchID = DispatchAbstract.DispatchID And
Customer.CustomerID = DispatchAbstract.CustomerID And
DispatchAbstract.DispatchID = @DISPATCHID And
Items.Sale_Tax *= Tax.Tax_Code 
AND DispatchDetail.Product_Code = Items.Product_Code    
AND DispatchDetail.Batch_Code *= Batch_Products.Batch_Code    
AND Items.UOM *= UOM.UOM     
AND ItemCategories.CategoryID = Items.CategoryID
And Items.BrandID = Brand.BrandID    
And Items.ManufacturerID = Manufacturer.ManufacturerID    
And Items.ConversionUnit *= ConversionTable.ConversionID    
Group by DispatchDetail.serial,DispatchDetail.Product_Code, Items.ProductName, Batch_Products.Batch_Number, 
DispatchDetail.SalePrice, Brand.BrandName, Manufacturer.Manufacturer_Name,  Manufacturer.ManufacturerCode,    
ConversionTable.ConversionUnit, Items.ConversionFactor, Batch_Products.Expiry, Items.Description, Customer.Locality,
ItemCategories.Category_Name, ItemCategories.Price_Option
