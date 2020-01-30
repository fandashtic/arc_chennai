CREATE Procedure [dbo].[SP_Print_RetInvItems_ITC_Template](@INVNO INT)      
	AS  
	/*    
	Declare @F As NVarchar(50) 
	Declare @S As NVarchar(50) 
	Set @F = dbo.LookupDictionaryItem(N'F',Default)
	Set @S = dbo.LookupDictionaryItem(N'S',Default)
	
	Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)
	Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)
	
	Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0
	
	SELECT
	 Identity(Int, 1, 1) as "id1",
	 "Item Code" = InvoiceDetail.Product_Code,
	 "Item Name" = Items.ProductName,       
	 "Batch" = Case When (IsNull(Items.TrackPKD, 0) = 1 And IsNull(Items.Virtual_Track_Batches, 0) = 0) Then N'' Else InvoiceDetail.Batch_Number End, 
	 "Quantity" = SUM(InvoiceDetail.Quantity),
	 "Free" = Cast(0 As Decimal(18,6)),
	 "UOM" = UOM.Description,       
	 "Sale Price" = 
	 Case InvoiceDetail.SalePrice
	   When 0 Then N'Free'
	   Else Cast((InvoiceDetail.SalePrice) As NVarChar)
	  End,
		"Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),       
		"Discount%" = Max(InvoiceDetail.DiscountPercentage),       
		"Scheme Discount%" = SUM(InvoiceDetail.SchemeDiscPercent),
		"Discount Value" = SUM(InvoiceDetail.DiscountValue),       
		"Amount" =SUM(InvoiceDetail.amount),  
		"Total Savings - Incl Discount" = (Sum(InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option   
			WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -       
			((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -        
			((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (Max(InvoiceDetail.DiscountPercentage) / 100))),      
		"Expiry" = CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS nVARCHAR) + N'/'      
			+ SubString(CAST(DATEPART(yy, Max(Batch_Products.Expiry)) AS nVARCHAR), 3, 2),      
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
		-- IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0), 
		"Spl Price" = Case ItemCategories.Price_Option When 1 Then Batch_Products.Company_Price Else Items.Company_Price End,
		"Excise duty" = IsNull(InvoiceDetail.ExciseDuty, 0)
	 ,"Serial" = InvoiceDetail.Serial, "TaxComponent" = NULL, "Sales Tax Credit" = InvoiceDetail.STCredit, "Sold As" = Items.Soldas
	INTO
	 #TmpInvDet  
	FROM
	 InvoiceDetail
	 Inner Join InvoiceAbstract On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	 Inner Join Items On  InvoiceDetail.Product_Code = Items.Product_Code                
	 Left Outer Join UOM On Items.UOM = UOM.UOM
	 Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
	 Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID 
	 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID      
	 Inner Join Brand On 	Items.BrandID = Brand.BrandID
	 Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM
	 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
	WHERE
	 InvoiceAbstract.InvoiceID = @INVNO
	GROUP BY
	 InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,  
	 InvoiceDetail.SalePrice, UOM.Description, 
--    (ISNULL(InvoiceDetail.TaxCode, 0) + ISNULL(InvoiceDetail.TaxCode2, 0)),
--	 CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'       
--	 	+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),      
--	 CAST(DATEPART(mm, Batch_Products.PKD) AS nVARCHAR) + N'/'      
--	 	+ SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nVARCHAR), 3, 2),      
		InvoiceDetail.SaleID,Manufacturer.ManufacturerCode, Items.Description,
	 ItemCategories.Category_Name,Items.ReportingUnit,Items.ConversionFactor,
	 Manufacturer.Manufacturer_Name,Brand.BrandName,RUOM.Description,
	 ConversionTable.ConversionID,ConversionTable.ConversionUnit,
	 InvoiceDetail.TaxID, InvoiceAbstract.TaxOnMRP, ItemCategories.Price_Option,  
		Items.TaxSuffered, Items.Sale_Tax, Items.MRP, InvoiceDetail.SalePriceBeforeExciseAmount,
		InvoiceDetail.ExciseDuty, Batch_Products.Company_Price, Items.Company_Price, 
		Items.TrackPKD, Items.Virtual_Track_Batches,InvoiceDetail.TaxID,InvoiceDetail.STCredit, Items.Soldas,
		InvoiceDetail.Serial
	Order By
	 InvoiceDetail.Product_Code,InvoiceDetail.SalePrice Desc
	
	Select @Cnt1 = Count(*) From #TmpInvDet Where [Sale Price] = N'Free'
	While @I < @Cnt1
	 Begin
	  Select 
	   Top 1 @IDS = [id1],  @FQty = [Quantity], @ItmC = [Item Code],@Batch = [Batch], @UOM = [UOM]
	  From
	   #TmpInvDet
	  Where
	   [Sale Price] = N'Free' And [id1] > @IDS
	  Order By
	   [id1]
	  
	  Select 
	   @Cnt2 = Count(*)
	  From
	   #TmpInvDet
	  Where 
	   [Item Code] = @ItmC And [Batch] = @Batch
	   And [UOM] = @UOM And [Sale Price] <> N'Free'
	  
	  Select
	   Top 1 @IDS1 = [id1]
	  From
	   #TmpInvDet
	  Where 
	   [Item Code] = @ItmC And [Batch] = @Batch
	   And [UOM] = @UOM And [Sale Price] <> N'Free'
	  Order By
	   [id1]
	  
	  Set @I1 = @Cnt2 - 1
	  While @I1 < @Cnt2
	   Begin
	    If @ids1 > 0
	     Update #TmpInvDet Set [Free] = [Free]+ @FQty Where [id1] = @IDS1
	    Else
	     Update #TmpInvDet Set  [Quantity] = Cast(0 As Decimal(18, 6)), [Free] = @FQty Where [id1] = @IDS
	    Set @I1 = @I1 + 1
	   End 
	  Select @I1 = 0, @IDS1 = 0
	  Set @I = @I + 1
	 End
	 
	 Delete From #TmpInvDet Where [Sale Price] = N'Free' And [Free] = 0
	
	 Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)), [Amount] = Cast(0 As Decimal(18,6)), [Item Gross Value] = Cast(0 As Decimal(18,6))
     Where [Sale Price] = N'Free'
	
	 Select * From #TmpInvDet Order By Serial

	Drop Table #TmpInvDet  
*/	
