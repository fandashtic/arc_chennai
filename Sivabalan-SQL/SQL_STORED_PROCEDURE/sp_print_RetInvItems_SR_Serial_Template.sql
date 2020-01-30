CREATE procedure [dbo].[sp_print_RetInvItems_SR_Serial_Template](@INVNO INT)    
AS 
Declare @cnt as int   
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
	"Batch" = InvoiceDetail.Batch_Number, "Quantity" = SUM(#Temp1.SRQty * InvoiceDetail.Quantity),    
	"UOM" = UOM.Description,     
	"Sale Price" = Case InvoiceDetail.SalePrice    
		When 0 then    
		N'Free'    
		Else    
		Cast(InvoiceDetail.SalePrice as nvarchar)    
		End,     
	"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),     
	"Discount%" = Max(InvoiceDetail.DiscountPercentage),     
	"Discount Value" = SUM(#Temp1.SRQty * InvoiceDetail.DiscountValue),     
	"Amount" = sum(InvoiceDetail.Amount),
	"Total Savings - Incl Discount" = (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option 
		WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -     
		((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -      
		((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (Max(InvoiceDetail.DiscountPercentage) / 100))),    
	"Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'    
		+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
		--"MRP" = InvoiceDetail.MRP, "PTS" = InvoiceDetail.PTS, "PTR" = InvoiceDetail.PTR,    
	"MRP" = CASE ItemCategories.Price_Option
		WHEN 1 THEN
		Max(InvoiceDetail.MRP)
		ELSE
		Max(Items.ECP)
		END,
	"PTS" = CASE ItemCategories.Price_Option
		WHEN 1 THEN
		Max(InvoiceDetail.PTS)
		ELSE
		Max(Items.PTS)
		END,
	"PTR" = CASE ItemCategories.Price_Option
		WHEN 1 THEN
		Max(InvoiceDetail.PTR)
		ELSE
		Max(Items.PTR)
		END,    
	"Spl Price" = CASE ItemCategories.Price_Option
		WHEN 1 THEN
		Max(Batch_Products.Company_Price)
		ELSE
		Max(Items.Company_Price)
		END,
	"Type" = CASE     
		WHEN InvoiceDetail.SaleID = 1 THEN N'F'    
		WHEN InvoiceDetail.SaleID = 2 THEN N'S'    
		WHEN InvoiceDetail.SaleID = 0 AND SUM(STPAYABLE) <> 0 THEN N'F'    
		ELSE N' '    
		END,    
	"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),    
	"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,    
	"Category" = ItemCategories.Category_Name,    
	"Item Gross Value" = Case Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice)    
		When 0 then    
		N''    
		Else    
		Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nvarchar)    
		End,    
	"Amount Before Tax" = Sum (#Temp1.SRQty * InvoiceDetail.Amount - #Temp1.SRQty *(InvoiceDetail.STPayable + InvoiceDetail.CSTPayable)),    
	"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),    
	"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),    
	"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),    
	"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
	"Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
	"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
	"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),    
	"Mfr Name" = Manufacturer.Manufacturer_Name,    
	"Divison" = Brand.BrandName,    
	"Tax Applicable Value" = Sum(IsNull(#Temp1.SRQty * InvoiceDetail.STPayable, 0) + IsNull(#Temp1.SRQty * InvoiceDetail.CSTPayable, 0)),    
	"Tax Suffered Value" =isnull(sum(invoicedetail.taxsuffamount),0),
	"Reporting UOM" = RUOM.Description,    
	"Conversion Unit" = ConversionTable.ConversionUnit,    
	"Reporting Factor" = Items.ReportingUnit,    
	"Conversion Factor" = Items.ConversionFactor,     
	"PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'    
		+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),    
	"Net Rate" = Cast(
		case InvoiceAbstract.TaxOnMRP 
		when 1 then 
		(case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)    
		WHEN 0 THEN     
		Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +     
		(SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option 
		WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)
		* dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6))     
		When 0 then    
		0    
		Else    
		Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +     
		(SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option 
		WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)
		* dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6)     
		End    
		ELSE    
		Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100), 6))    
		When 0 then    
		0
		Else    
		Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))  
		End    
		END) 
		else -- when TaxOnMRP = 0
		(case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)    
		WHEN 0 THEN     
		Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100) +     
		(((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
		- (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100))     
		* Max(InvoiceDetail.TaxCode) / 100), 6))    
		When 0 then    
		0    
		Else    
		Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100) +     
		(((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)     
		- (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100))     
		* Max(InvoiceDetail.TaxCode) / 100), 6) as Decimal(18,6))    
		End    
		ELSE    
		Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100), 6))    
		When 0 then    
		0    
		Else    
		Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -     
		(SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *     
		Max(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))    
		End    
		END) 
		end
		/ Sum(Invoicedetail.Quantity) As Decimal(18,6)),     
	"Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.Quantity) As Decimal(18,6)), 
	"Net Value" = Sum(#Temp1.SRQty * Amount), 
	"Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),
	"Sales Tax Desc" = (select Tax_description from Tax where tax_code = items.Sale_Tax),
	"Item MRP" = isnull(Items.MRP,0), 
	"SPBED" = IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0), 
	"Excise duty" = IsNull(InvoiceDetail.ExciseDuty, 0), "TaxComponents"=N'TaxComponents' into #tmp3   
	FROM InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand,    
	UOM As RUOM, ConversionTable, InvoiceAbstract,#Temp1
	WHERE InvoiceAbstract.InvoiceID =#Temp1.invno               
	And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
	AND InvoiceDetail.Product_Code = Items.Product_Code    
	AND Items.UOM *= UOM.UOM    
	AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code    
	AND Items.ManufacturerID *= Manufacturer.ManufacturerID     
	AND Items.CategoryID = ItemCategories.CategoryID    
	And Items.BrandID = Brand.BrandID    
	And Items.ReportingUOM *= RUOM.UOM    
	And Items.ConversionUnit *= ConversionTable.ConversionID    
	GROUP BY  #Temp1.InvID,InvoiceDetail.Serial,InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,
	InvoiceDetail.SalePrice, UOM.Description, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'     
	+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),    
	CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'    
	+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),    
	--InvoiceDetail.MRP, InvoiceDetail.PTS, InvoiceDetail.PTR,     
	InvoiceDetail.SaleID,    
	Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,    
	Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,    
	Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,     
	ConversionTable.ConversionUnit, InvoiceDetail.TaxID, InvoiceAbstract.TaxOnMRP, ItemCategories.Price_Option,
	Items.TaxSuffered, Items.Sale_Tax, Items.MRP,#Temp1.Invno, 
	InvoiceDetail.SalePriceBeforeExciseAmount,
	InvoiceDetail.ExciseDuty
	Order By #Temp1.Invid,InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.SalePrice Desc 
--To Insert A Line Gap And Label Before Sales Return
Select * into #tmp4 from #tmp3 where 1=2
Alter Table #tmp4 Alter Column [Item Code] Nvarchar(35)
Insert into #tmp4([Item Code]) values('')
Insert into #tmp4([Item Code]) values('Sales Return Saleable/Damages')
Select @cnt=COUNT(*) FROM #tmp3 where #tmp3.Quantity < 0 
IF @cnt <>0
begin 
Select * from #tmp3  where #tmp3.Quantity >0  
union all
Select * from #tmp4 
Union all
select * from #tmp3 where #tmp3.Quantity <0  
end
else
Select * from #tmp3 
Drop Table #tmp3
Drop Table #Temp1
