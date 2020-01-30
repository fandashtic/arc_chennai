CREATE Procedure SP_Print_RetInvItems(@INVNO INT)      
AS      
Declare @FREE As NVarchar(50)
Declare @F As NVarchar(50) 
Declare @S As NVarchar(50) 
Set @FREE = dbo.LookupDictionaryItem(N'Free',Default)
Set @F = dbo.LookupDictionaryItem(N'F',Default)
Set @S = dbo.LookupDictionaryItem(N'S',Default)

SELECT "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName,       
	"Batch" = Case When (IsNull(Items.TrackPKD, 0) = 1 And IsNull(Items.Virtual_Track_Batches, 0) = 0) Then '' Else InvoiceDetail.Batch_Number End, 
	"Quantity" = SUM(InvoiceDetail.Quantity),      
	"UOM" = UOM.Description,       
	"Sale Price" = Case InvoiceDetail.SalePrice      
		When 0 then      
		@FREE  
		Else      
		Cast(InvoiceDetail.SalePrice as nVarchar)      
		End,       
	"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),       
	"Discount%" = Max(InvoiceDetail.DiscountPercentage),       
	"Scheme Discount%" = Max(InvoiceDetail.SchemeDiscPercent),
	"Discount Value" = SUM(InvoiceDetail.DiscountValue),       
	"Scheme Disc Amt" = SUM(InvoiceDetail.SchemeDiscAmount),
	"Amount" =SUM(InvoiceDetail.amount),  
	"Total Savings - Incl Discount" = (Sum(InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option   
		WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -       
		((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -        
		((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (Max(InvoiceDetail.DiscountPercentage) / 100))),      
	"Expiry" = CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS nVARCHAR) + N'/'      
		+ SubString(CAST(DATEPART(yy, Max(Batch_Products.Expiry)) AS nVARCHAR), 3, 2),   
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
	"Type" = CASE       
		WHEN InvoiceDetail.SaleID = 1 THEN @F
		WHEN InvoiceDetail.SaleID = 2 THEN @S
		WHEN InvoiceDetail.SaleID = 0 AND SUM(STPAYABLE) <> 0 THEN @F      
		ELSE N' '      
		END,      
	"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),      
	"Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,      
	"Category" = ItemCategories.Category_Name,      
	"Item Gross Value" = Case Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice)      
		When 0 then      
		N''      
		Else      
		Cast(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nVarchar)      
		End,      
	"Amount Before Tax" = Sum (InvoiceDetail.Amount - (InvoiceDetail.STPayable + InvoiceDetail.CSTPayable)),      
	"Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
	"Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
	"Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
	"Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),      
	"Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),      
	"Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),      
	"Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),      
	"Mfr Name" = Manufacturer.Manufacturer_Name,      
	"Divison" = Brand.BrandName,      
	"Tax Applicable Value" = Sum(IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0)),      
	"Tax Suffered Value" =  isnull(sum(invoicedetail.taxsuffamount),  0),
	"Reporting UOM" = RUOM.Description,      
	"Conversion Unit" = ConversionTable.ConversionUnit,      
	"Reporting Factor" = Items.ReportingUnit,      
	"Conversion Factor" = Items.ConversionFactor,       
	"PKD" = CAST(DATEPART(mm, Max(Batch_Products.PKD)) AS nVARCHAR) + N'/'      
		+ SubString(CAST(DATEPART(yy, Max(Batch_Products.PKD)) AS nVARCHAR), 3, 2),      
	"Net Rate" = Cast(  
		case InvoiceAbstract.TaxOnMRP   
		when 1 then   
		(case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)      
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
		(case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)      
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
		/ Sum(Invoicedetail.Quantity) As Decimal(15,6)),       
	"Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.Quantity) As Decimal(18,6)),   
	"Net Value" = Sum(Amount),   
	"Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),  
	"Sales Tax Desc" = (select Tax_description from Tax where tax_code = InvoiceDetail.TaxID),  
	"Item MRP" = isnull(Items.MRP,0), 
	-- Sum(IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0)), 
	"Spl Price" = Case ItemCategories.Price_Option When 1 Then Max(Batch_Products.Company_Price) Else Max(Items.Company_Price) End,
	"Excise duty" = IsNull(InvoiceDetail.ExciseDuty, 0) , "Sales Tax Credit" = InvoiceDetail.STCredit, "Sold As" = Items.Soldas
	FROM InvoiceDetail
	Inner Join InvoiceAbstract On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
	Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code      
	Left Outer Join UOM On Items.UOM = UOM.UOM
	Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
	Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
	Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
	Inner Join Brand On Items.BrandID = Brand.BrandID      
	Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM
	Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID      
	WHERE InvoiceAbstract.InvoiceID = @INVNO   
	GROUP BY Invoicedetail.invoiceid, InvoiceDetail.Product_code, Items.ProductName,  
 InvoiceDetail.Batch_Number,InvoiceDetail.SalePrice,  
 InvoiceDetail.TaxID,
 -- (ISNULL(InvoiceDetail.TaxCode, 0) + ISNULL(InvoiceDetail.TaxCode2, 0)),
 -- CAST(DATEPART(mm, Batch_Products.Expiry) AS NVARCHAR) + N'/'             
 -- + SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS NVARCHAR), 3, 2),            
 -- CAST(DATEPART(mm, Batch_Products.PKD) AS NVARCHAR) + N'/'            
 -- + SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS NVARCHAR), 3, 2),            
 InvoiceDetail.SaleID,Manufacturer.ManufacturerCode,Items.Description,  
 ItemCategories.Category_Name,Items.ReportingUnit,Items.ConversionFactor,  
 Manufacturer.Manufacturer_Name,Brand.BrandName,RUOM.Description,UOM.Description,  
 ConversionTable.ConversionID,ConversionTable.ConversionUnit,InvoiceAbstract.TaxONMRP,  
 Items.TrackPKD, Items.Virtual_Track_Batches,Items.MRP,-- IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0),
 InvoiceDetail.ExciseDuty,
 ItemCategories.Price_Option,Items.TaxSuffered, Items.Sale_Tax, InvoiceDetail.STCredit, Items.Soldas
--,InvoiceDetail.Serial
 
Order By  
 InvoiceDetail.Product_Code,InvoiceDetail.SalePrice Desc  


