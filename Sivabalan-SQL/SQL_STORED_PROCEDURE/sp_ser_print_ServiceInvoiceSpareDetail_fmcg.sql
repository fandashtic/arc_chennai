CREATE PROCEDURE sp_ser_print_ServiceInvoiceSpareDetail_fmcg(@INVNO INT)    
AS    
-- ServiceInvoiceDetail for FMCG
SELECT 
"Item Code" = ItemsProd.Product_Code, "Item name" = ItemsProd.ProductName, 
"Item Spec1" = IsNull(SDetail.Product_Specification1, ''), 
"Item Spec2" = IsNull(IInfo.Product_Specification2, ''), 
"Item Spec3" = IsNull(IInfo.Product_Specification3, ''), 
"Item Spec4" = IsNull(IInfo.Product_Specification4, ''), 
"Item Spec5" = IsNull(IInfo.Product_Specification5, ''), 
"Spare Code" = SDetail.SpareCode, 
"Spare Name" = ItemsSpare.ProductName,     
"Batch" = SDetail.Batch_Number, 
"Quantity" = (SDetail.Quantity),    
"UOM" = UOM.Description,     
"Sale Price" = Case SDetail.Price    
	When 0 then 'Free' Else Cast(SDetail.Price as Varchar)    
	End,     
"Tax%" = Isnull((SaleTax), 0),
"Tax value" = Isnull(LSTPayable, 0) + Isnull(CSTPayable, 0), 
"Warranty Number" = Isnull(SDetail.WarrantyNo, ''),
"DateofSale" = SDetail.DateofSale, 
"Discount%" = (SDetail.ItemDiscountPercentage),     
"Discount Value" = (SDetail.ItemDiscountValue),     
"Amount" = SDetail.Amount,
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS VARCHAR) + '/'    
	+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS VARCHAR), 3, 2),    
"MRP" = CASE ItemCategories.Price_Option
	WHEN 1 THEN 
	(IDetail.MRP)
	ELSE
	(ItemsSpare.MRP)
	END,    
"Type" = CASE     
	 WHEN SDetail.SaleID = 1 THEN 'F'    
	 WHEN SDetail.SaleID = 2 THEN 'S'    
	 WHEN SDetail.SaleID = 0 AND (LSTPAYABLE) <> 0 THEN 'F'    
	 ELSE ' '    
	 END,    
"Tax Suffered" = ISNULL((SDetail.TaxSuffered), 0),    
"Item Gross Value" = Case (SDetail.Quantity * SDetail.Price)    
	When 0 then '' Else Cast((SDetail.Quantity * SDetail.Price) as Varchar)    
	End,    
--Amount Before Tax =  (SDetail.Amount - (SDetail.LSTPayable + SDetail.CSTPayable)),    
"Amount Before Tax" =  Isnull(SDetail.Amount,0),
"Tax Applicable Value" = (IsNull(SDetail.LSTPayable, 0) + IsNull(SDetail.CSTPayable, 0)),    
"Tax Suffered Value" = IsNull((SDetail.Quantity * 
		SDetail.Price * SDetail.TaxSuffered / 100), 0),
"Net Value" = SDetail.NetValue, 
"Net Rate" = Cast( (Sdetail.NetValue) / (Sdetail.Quantity) As Decimal(18,6)),     
"Net Item Rate" = Cast((SDetail.Amount) / (SDetail.Quantity) As Decimal(18,6)),
"Property1" = dbo.GetProperty(SDetail.SpareCode, 1),    
"Property2" = dbo.GetProperty(SDetail.SpareCode, 2),    
"Property3" = dbo.GetProperty(SDetail.SpareCode, 3),    
"Reporting Unit Qty" = ((SDetail.Quantity) / 
	(Case IsNull(ItemsSpare.ReportingUnit, 0) When 0 Then 1 Else ItemsSpare.ReportingUnit End)),    
"Conversion Unit Qty" = ((SDetail.Quantity) * ItemsSpare.ConversionFactor),    
"Rounded Reporting Unit Qty" = Ceiling((SDetail.Quantity) / 
	(Case IsNull(ItemsSpare.ReportingUnit, 0) When 0 Then 1 Else ItemsSpare.ReportingUnit End)),    
"Rounded Conversion Unit Qty" = Ceiling((SDetail.Quantity) * ItemsSpare.ConversionFactor),    
"Description" = ItemsSpare.Description,    
"Category" = ItemCategories.Category_Name,    
"Mfr" = Manufacturer.ManufacturerCode, 
"Mfr Name" = Manufacturer.Manufacturer_Name,    
"Divison" = Brand.BrandName,    
"Reporting UOM" = RUOM.Description,    
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Reporting Factor" = ItemsSpare.ReportingUnit,    
"Conversion Factor" = ItemsSpare.ConversionFactor,     
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS VARCHAR) + '/'    
	+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS VARCHAR), 3, 2),    

"Tax Suffered Desc" = (Select Tax_description from Tax where tax_code = ItemsSpare.TaxSuffered),
"Sales Tax Desc" = (select Tax_description from Tax where tax_code = ItemsSpare.Sale_Tax)
FROM ServiceInvoiceDetail SDetail 
Inner Join Items ItemsSpare On ItemsSpare.Product_Code = SDetail.SpareCode 
Inner Join ItemCategories On ItemsSpare.CategoryID = ItemCategories.CategoryID
Inner Join Brand On ItemsSpare.BrandID = Brand.BrandID 

Left Outer Join (Select si.ServiceInvoiceID, si.Product_Code, si.Product_Specification1, 
	i.Product_Specification2, i.Product_Specification3, 
	i.Product_Specification4, i.Product_Specification5, i.Color 
	from ServiceInvoiceDetail si 
	Left Outer Join ItemInformation_Transactions i On 
		i.DocumentID = si.SerialNo and i.DocumentType = 3
	where si.ServiceInvoiceID = @INVNO and si.Type = 0) IInfo 
On IInfo.ServiceInvoiceID = SDetail.ServiceInvoiceID and IInfo.Product_Code = SDetail.Product_Code 
	and IInfo.Product_Specification1 = SDetail.Product_Specification1
Left Join IssueDetail IDetail On SDetail.Issue_Serial = IDetail.SerialNo
--Inner Join IssueDetail IDetail On SDetail.Issue_Serial = IDetail.SerialNo
Inner Join Items ItemsProd On ItemsProd.Product_Code = SDetail.Product_Code 
Left Outer Join Manufacturer On ItemsSpare.ManufacturerID = Manufacturer.ManufacturerID 
Left Outer Join Batch_Products On SDetail.Batch_Code = Batch_Products.Batch_Code
Left Outer Join UOM On ItemsSpare.UOM = UOM.UOM    
Left Outer Join UOM RUOM On ItemsSpare.ReportingUOM = RUOM.UOM
Left Outer Join ConversionTable On ItemsSpare.ConversionUnit = ConversionTable.ConversionID
WHERE SDetail.ServiceInvoiceID = @INVNO and IsNull(SDetail.SpareCode, '') <> '' 
Order By SDetail.SerialNo







