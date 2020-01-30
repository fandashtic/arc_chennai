CREATE PROCEDURE sp_ser_print_EstimationSpareDetail(@EstID INT)    
AS    

SELECT 
"Item Code" = ItemsProd.Product_Code, "Item name" = ItemsProd.ProductName, 
"Item Spec1" = IsNull(EDetail.Product_Specification1, ''), 
"Item Spec2" = IsNull(IInfo.Spec2, ''), 
"Item Spec3" = IsNull(IInfo.Spec3, ''), 
"Item Spec4" = IsNull(IInfo.Spec4, ''), 
"Item Spec5" = IsNull(IInfo.Spec5, ''), 
"Spare Code" = EDetail.SpareCode, 
"Spare Name" = ItemsSpare.ProductName,     
"Description" = ItemsSpare.Description,
"Quantity" = (EDetail.Quantity),    
"UOM" = UOM.Description,     
"Sale Price" = Case EDetail.Price    
	When 0 then 'Free' Else Cast(EDetail.Price as Varchar)    
	End,     
"Tax%" = Isnull((SalesTax), 0),
"Tax value" = Isnull(LSTPayable, 0) + Isnull(CSTPayable, 0), 
"Amount" = Case (EDetail.Quantity * EDetail.Price)    
	When 0 then '' Else Cast((EDetail.Quantity * EDetail.Price) as Varchar)    
	End,    
"Tax Suffered" = ISNULL((EDetail.TaxSuffered), 0),    
"Tax Suffered Value" = IsNull((EDetail.Quantity * 
		EDetail.Price * EDetail.TaxSuffered / 100), 0),
"Net Value" = EDetail.NetValue, 
"Net Rate" = Cast( (EDetail.NetValue) / (EDetail.Quantity) As Decimal(18,6)),
"Net Item Rate" = Cast((EDetail.Amount) / (EDetail.Quantity) As Decimal(18,6)),
"Property1" = dbo.GetProperty(EDetail.SpareCode, 1),    
"Property2" = dbo.GetProperty(EDetail.SpareCode, 2),    
"Property3" = dbo.GetProperty(EDetail.SpareCode, 3),    
"Reporting Unit Qty" = ((EDetail.Quantity) / 
	(Case IsNull(ItemsSpare.ReportingUnit, 0) When 0 Then 1 Else ItemsSpare.ReportingUnit End)),    
"Conversion Unit Qty" = ((EDetail.Quantity) * ItemsSpare.ConversionFactor),    
"Rounded Reporting Unit Qty" = Ceiling((EDetail.Quantity) / 
	(Case IsNull(ItemsSpare.ReportingUnit, 0) When 0 Then 1 Else ItemsSpare.ReportingUnit End)),    
"Rounded Conversion Unit Qty" = Ceiling((EDetail.Quantity) * ItemsSpare.ConversionFactor),        
"Category" = ItemCategories.Category_Name,    
"Mfr" = Manufacturer.ManufacturerCode, 
"Mfr Name" = Manufacturer.Manufacturer_Name,    
"Divison" = Brand.BrandName,    
"Reporting UOM" = RUOM.Description,    
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Reporting Factor" = ItemsSpare.ReportingUnit,    
"Conversion Factor" = ItemsSpare.ConversionFactor,     
"Tax Suffered Desc" = (Select Tax_description from Tax where tax_code = ItemsSpare.TaxSuffered),
"Sales Tax Desc" = (select Tax_description from Tax where tax_code = ItemsSpare.Sale_Tax)
FROM EstimationDetail EDetail 
Inner Join Items ItemsSpare On ItemsSpare.Product_Code = EDetail.SpareCode 
Inner Join ItemCategories On ItemsSpare.CategoryID = ItemCategories.CategoryID
Inner Join Brand On ItemsSpare.BrandID = Brand.BrandID 
Left Outer Join 
	(Select ie.EstimationID EID, ie.Product_Code, ie.Product_Specification1 Spec1, 
	i.Product_Specification2 Spec2, i.Product_Specification3 Spec3, 
	i.Product_Specification4 Spec4, i.Product_Specification5 Spec5, 
	i.Color, i.DateofSale, i.SoldBy
	From EstimationDetail ie
	Left Outer Join ItemInformation_Transactions i On 
		i.DocumentID = ie.SerialNo and i.DocumentType = 1
	Where 
	ie.SerialNo in (Select Min(g.Serialno) From EstimationDetail g 
		Where g.EstimationID = @EstID Group by g.Product_Specification1)) IInfo 
	On IInfo.Product_Code = EDetail.Product_Code 
	and IInfo.Spec1 = EDetail.Product_Specification1

Inner Join Items ItemsProd On ItemsProd.Product_Code = EDetail.Product_Code 
Left Outer Join Manufacturer On ItemsSpare.ManufacturerID = Manufacturer.ManufacturerID 
Left Outer Join UOM On ItemsSpare.UOM = UOM.UOM    
Left Outer Join UOM RUOM On ItemsSpare.ReportingUOM = RUOM.UOM
Left Outer Join ConversionTable On ItemsSpare.ConversionUnit = ConversionTable.ConversionID
WHERE EDetail.EstimationId = @EstID and IsNull(EDetail.SpareCode, '') <> '' 
Order By EDetail.SerialNo








