CREATE procedure [dbo].[sp_print_DispatchItems_MultiUOM] (@DISPATCHID INT)    
AS    

SELECT "Item Code" = Max(DispatchDetail.Product_Code), "Item Name" = Max(Items.ProductName),     
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(Max(DispatchDetail.Product_Code), Sum(DispatchDetail.Quantity)),
"UOM2Description" = (Select Max(UOM.Description) from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Max(DispatchDetail.Product_Code) )),
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(Max(DispatchDetail.Product_Code), Sum(DispatchDetail.Quantity)),
"UOM1Description" = (Select Max(UOM.Description) from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Max(DispatchDetail.Product_Code ))),
"UOMQuantity" = dbo.GetLastLevelUOMQty(Max(DispatchDetail.Product_Code), Sum(DispatchDetail.Quantity)),
"UOMDescription" = (Select Max(UOM.Description) from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Max(DispatchDetail.Product_Code ))),
"Batch" = Max(Batch_Products.Batch_Number),     
"Sale Price" = Max(DispatchDetail.SalePrice),    
"Amount" = Sum(DispatchDetail.Quantity) * Max(DispatchDetail.SalePrice),    
"Expiry" = CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS NVARCHAR) + '\'  
+ CAST(DATEPART(yyyy, Max(Batch_Products.Expiry)) AS NVARCHAR),  
"Division" = Max(Brand.BrandName), "Manufacturer Name" = Max(Manufacturer.Manufacturer_Name),    
"Manufacturer Code" = Max(Manufacturer.ManufacturerCode),
"Description" = Max(Items.Description),     
"Conversion Unit" = Max(ConversionTable.ConversionUnit),    
"Conversion Factor" = Max(Items.ConversionFactor),
"Sales Tax (%)" = Cast(Case Max(Customer.Locality) 
WHEN 1 THEN
IsNull(Sum(Tax.Percentage),0)
ELSE
IsNull(Sum(Tax.CST_Percentage),0)
END As Decimal(18,6)),
"Sales Tax Value" = Cast(Case Max(Customer.Locality) 
WHEN 1 THEN
Sum(DispatchDetail.Quantity) * Max(DispatchDetail.SalePrice) * (IsNull(Sum(Tax.Percentage),0)/100)
ELSE
Sum(DispatchDetail.Quantity) * Max(DispatchDetail.SalePrice) * (IsNull(Sum(Tax.CST_Percentage),0)/100)
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
Group by 
	DispatchDetail.Serial
Order By
	DispatchDetail.Serial
