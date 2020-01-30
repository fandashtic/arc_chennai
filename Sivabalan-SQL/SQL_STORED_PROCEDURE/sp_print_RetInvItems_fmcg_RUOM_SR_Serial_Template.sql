CREATE procedure [dbo].[sp_print_RetInvItems_fmcg_RUOM_SR_Serial_Template](@INVNO INT)    
AS  
--1 is set in SrQty when it is a Normal Invoice /SR and -1 for those SR which are adjusted
 	Create Table #Temp1 (InvID int identity(1,1), invno int,SRQty Decimal(18,6))
 	INsert into #Temp1(Invno,SRQty) Values (@invno,1)

	If (SELECT Count(CollectionDetail.DocumentID) FROM CollectionDetail,InvoiceAbstract
	 	Where InvoiceAbstract.InvoiceId = @invno and ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID
 		And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)) > 0 
	Begin
 	INsert into #Temp1(Invno,SRQty) 
 			SELECT CollectionDetail.DocumentID,-1 FROM CollectionDetail,InvoiceAbstract
		 	Where InvoiceAbstract.InvoiceId = @invno and ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID
 			And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)
	End
  
SELECT "Item Code" = InvoiceDetail.Product_Code, "Item Name" = Items.ProductName,         
"Batch" = InvoiceDetail.Batch_Number, "Quantity" = Sum(#Temp1.SRQty * InvoiceDetail.UOMQty),        
"UOM" = UOM.Description,         
"Sale Price" = Case Max(InvoiceDetail.UOMPrice)      
When 0 then        
'Free'        
Else        
Cast(Max(InvoiceDetail.UOMPrice) as nvarchar)        
End,         
"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),         
"Discount%" = Max(InvoiceDetail.DiscountPercentage),         
"Discount Value" = Sum(#Temp1.SRQty * InvoiceDetail.DiscountValue),         
"Amount" = sum(InvoiceDetail.Amount),        
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + '\'        
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),        
"MRP" = CASE ItemCategories.Price_Option
WHEN 1 THEN
Max(InvoiceDetail.MRP)
ELSE
Max(Items.MRP)
END, 
"Type" = CASE         
 WHEN InvoiceDetail.SaleID = 1 THEN 'F'        
 WHEN InvoiceDetail.SaleID = 2 THEN 'S'        
 WHEN InvoiceDetail.SaleID = 0 AND Max(InvoiceDetail.STPayable) <> 0 THEN 'F'        
 ELSE ' '        
 END,        
"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),        
"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,        
"Category" = ItemCategories.Category_Name,        
"Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice        
When 0 then        
NULL        
Else        
Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)        
End,        
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),        
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),        
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),        
"Net Amount" = Sum(#Temp1.SRQty * Amount),    
"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),        
"Conversion Unit Qty" = Sum(InvoiceDetail.Quantity) * Items.ConversionFactor,        
"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),        
"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),        
"Mfr Name" = Manufacturer.Manufacturer_Name,        
"Divison" = Brand.BrandName,        
"Tax Applicable Value" = IsNull(Sum(#Temp1.SRQty * InvoiceDetail.STPayable), 0) + IsNull(Sum(#Temp1.SRQty * InvoiceDetail.CSTPayable), 0),        
"Tax Suffered Value" = isnull(sum(invoicedetail.taxsuffamount),0),      
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + '\'      
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),        
"Net Rate" = Cast((case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)        
WHEN 0 THEN         
 Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -         
 (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100) +         
 ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice         
 - (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100))         
 * Max(InvoiceDetail.TaxCode) / 100))        
 When 0 then        
 NULL        
 Else        
 Cast(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice -         
 (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100) +         
 ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice         
 - (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100))         
 * Max(InvoiceDetail.TaxCode) / 100) as nvarchar)        
 End        
ELSE        
 Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -         
 (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100))        
 When 0 then        
 NULL        
 Else        
 Cast((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -         
 (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *         
 Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)        
 End        
END) / CASE WHEN Sum(InvoiceDetail.UOMQty) = 0 THEN 1 ELSE Sum(InvoiceDetail.UOMQty) END As Decimal(18,6)),       
"Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.UOMQty) As Decimal(18,6)),
"Item MRP" = isnull(Items.MRP,0), 'TaxComponents'      
FROM InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand,        
UOM As RUOM, ConversionTable ,#Temp1
WHERE InvoiceDetail.InvoiceID =#Temp1.invno            
AND InvoiceDetail.Product_Code = Items.Product_Code        
AND InvoiceDetail.UOM *= UOM.UOM        
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code        
AND Items.ManufacturerID *= Manufacturer.ManufacturerID         
AND Items.CategoryID = ItemCategories.CategoryID        
And Items.BrandID = Brand.BrandID        
And Items.ReportingUOM *= RUOM.UOM        
And Items.ConversionUnit *= ConversionTable.ConversionID     
GROUP BY #Temp1.InvID,InvoiceDetail.Serial,InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,       
InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + '\'       
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),      
CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + '\'      
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),      
--InvoiceDetail.MRP, InvoiceDetail.PTS, InvoiceDetail.PTR,       
InvoiceDetail.SaleID,ItemCategories.Price_Option,
Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,      
Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,      
Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,       
ConversionTable.ConversionUnit, UOM.Description, Items.MRP, InvoiceDetail.TaxID,#Temp1.Invno



Drop table #Temp1
