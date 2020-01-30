CREATE procedure [dbo].[sp_print_RetInvItems_fmcg_MUOM_SR_Serial_Template](@INVNO INT)    
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
"Batch" = InvoiceDetail.Batch_Number,     
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty * InvoiceDetail.Quantity)),    
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),    
"UOM2Price" =  Isnull(Max(UOM2_Conversion),0) *
	(Case ItemCategories.Price_Option 
	When 1 Then Max(InvoiceDetail.MRP) 
	Else Max(Items.MRP) 
	End),
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty * InvoiceDetail.Quantity)),    
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),    
"UOM1Price" =  Isnull(Max(UOM1_Conversion),0) *
	(Case ItemCategories.Price_Option 
	When 1 Then Max(InvoiceDetail.MRP) 
	Else Max(Items.MRP) 
	End),
"UOMQuantity" = dbo.GetLastLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty * InvoiceDetail.Quantity)),    
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),      
"UOMPrice" =  
	(Case ItemCategories.Price_Option 
	When 1 Then Max(InvoiceDetail.MRP) 
	Else Max(Items.MRP) 
	End),
"Sale Price" = InvoiceDetail.SalePrice,     
"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),    
"Discount%" = MAX(InvoiceDetail.DiscountPercentage),     
"Discount Value" = SUM(#Temp1.SRQty * InvoiceDetail.DiscountValue),     
"Amount" = sum(InvoiceDetail.Amount),    
"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
"MRP" = CASE ItemCategories.Price_option
WHEN 1 THEN
Max(InvoiceDetail.MRP)
ELSE
Max(Items.MRP)
END,    
"Type" = CASE     
 WHEN InvoiceDetail.SaleID = 1 THEN N'F'    
 WHEN InvoiceDetail.SaleID = 2 THEN N'S'    
 WHEN InvoiceDetail.SaleID = 0 AND SUM(STPAYABLE) <> 0 THEN N'F'    
 ELSE N' '    
 END ,    
"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),    
"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,    
"Category" = ItemCategories.Category_Name,    
"Item Gross Value" = Case Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice)    
When 0 then    
N''    
Else    
Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nvarchar)    
End,    
"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),    
"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),    
"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),    
"Net Amount" = Sum(#Temp1.SRQty * Amount),    
"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
"Mfr Name" = Manufacturer.Manufacturer_Name,    
"Divison" = Brand.BrandName,    
"Tax Applicable Value" = Sum(IsNull(#Temp1.SRQty * InvoiceDetail.STPayable, 0) + IsNull(#Temp1.SRQty * InvoiceDetail.CSTPayable, 0)),    
"Tax Suffered Value" = isnull(sum(invoicedetail.taxsuffamount),0),
"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),    
"Net Rate" = Cast((case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)    
    WHEN 0 THEN Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
    - (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice     
    * MAX(InvoiceDetail.DiscountPercentage) / 100) +     
    (((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
    - (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice     
    * MAX(InvoiceDetail.DiscountPercentage) / 100))     
    * Max(InvoiceDetail.TaxCode) / 100), 6)    
    ELSE Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
    - (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice     
    * MAX(InvoiceDetail.DiscountPercentage) / 100), 6)    
    END) / SUM(InvoiceDetail.Quantity) As Decimal(18,6)),     
"Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.Quantity) As Decimal(18,6)),
"Item MRP" = isnull(Items.MRP,0), N'TaxComponents'     
FROM InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand,#Temp1
WHERE InvoiceDetail.InvoiceID =#Temp1.invno            
AND InvoiceDetail.Product_Code = Items.Product_Code    
AND Items.UOM *= UOM.UOM    
AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code    
AND Items.ManufacturerID *= Manufacturer.ManufacturerID    
AND Items.CategoryID = ItemCategories.CategoryID    
And Items.BrandID = Brand.BrandID    
GROUP BY #Temp1.Invid,InvoiceDetail.Serial,InvoiceDetail.Product_code, Items.ProductName,     
InvoiceDetail.Batch_Number, ItemCategories.Price_Option,    
InvoiceDetail.SalePrice, UOM.Description,     
CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'\'    
+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),    
InvoiceDetail.SaleID, Manufacturer.ManufacturerCode,    
Items.Description, ItemCategories.Category_Name,    
Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,    
Brand.BrandName, InvoiceDetail.TaxID, Items.MRP,#Temp1.Invno
Order By #Temp1.Invid,InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.SalePrice Desc


Drop Table #Temp1
