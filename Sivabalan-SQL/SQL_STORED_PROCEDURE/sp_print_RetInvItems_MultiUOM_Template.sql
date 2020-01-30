CREATE procedure [dbo].[sp_print_RetInvItems_MultiUOM_Template](@INVNO INT)      
AS      
  
SELECT "Item Code" = InvoiceDetail.Product_Code, "Item Name" = Items.ProductName,       
 "UOM2Quantity" = dbo.GetFirstLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
 "UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),      
 "UOM2Price" =  Isnull(Max(UOM2_Conversion),0) *  
  (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
  Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
  End),  
 "UOM1Quantity" = dbo.GetSecondLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
 "UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),      
 "UOM1Price" =  Isnull(Max(UOM1_Conversion),0) *  
  (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
  Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
  End),   
 "UOMQuantity" = dbo.GetLastLevelUOMQty(InvoiceDetail.Product_Code, Sum(InvoiceDetail.Quantity)),      
 "UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  InvoiceDetail.Product_Code )),        
 "UOMPrice" =   
  (Case ItemCategories.Price_Option   
  When 1 Then  
  Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
  Else  
  Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
  End),   
 "Batch" = InvoiceDetail.Batch_Number,       
 "Sale Price" = Case InvoiceDetail.SalePrice      
  When 0 then      
  N'Free'      
  Else      
  Cast(InvoiceDetail.SalePrice as nvarchar)      
  End,       
 "Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),       
 "Discount%" = MAX(InvoiceDetail.DiscountPercentage),       
 "Scheme Discount%" = MAX(InvoiceDetail.SchemeDiscPercent),  
 "Discount Value" = SUM(InvoiceDetail.DiscountValue),       
 "Amount" = sum(InvoiceDetail.Amount),      
 "Total Savings - Incl Discount" = (Sum(InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option   
  WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -       
  ((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -        
  ((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (MAX(InvoiceDetail.DiscountPercentage) / 100))),      
 "Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'      
  + SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),      
 "MRP" = CASE ItemCategories.Price_Option  
  WHEN 1 THEN   
  Max(InvoiceDetail.MRP)   
  ELSE   
  Max(Items.ECP) END,  
 "PTS" = CASE ItemCategories.Price_Option  
  WHEN 1 THEN   
  Max(InvoiceDetail.PTS)   
  ELSE   
  Max(Items.PTS) END,   
 "PTR" = CASE ItemCategories.Price_Option  
  WHEN 1 THEN   
  Max(InvoiceDetail.PTR)   
  ELSE   
  Max(Items.PTR) END,   
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
  Cast(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nvarchar)      
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
 "Tax Suffered Value" = isnull(sum(invoicedetail.taxsuffamount),  0),  
 "Reporting UOM" = RUOM.Description,      
 "Conversion Unit" = ConversionTable.ConversionUnit,      
 "Reporting Factor" = Items.ReportingUnit,      
 "Conversion Factor" = Items.ConversionFactor,       
 "PKD" = CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'      
  + SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),       
 "Net Rate" = Cast(  
  case IsNull(InvoiceAbstract.TaxOnMRP,0)  
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
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
  When 0 then      
  0      
  Else      
  Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))      
  End      
  END)   
  else --when TaxOnMRP = 0  
  (case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)      
  WHEN 0 THEN       
  Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100) +       
  (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
  - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100))       
  * Max(InvoiceDetail.TaxCode) / 100), 6))      
  When 0 then      
  0      
  Else      
  Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100) +       
  (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
  - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100))       
  * Max(InvoiceDetail.TaxCode) / 100), 6) as Decimal(18,6))      
  End      
  ELSE      
  Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
  When 0 then      
  0      
  Else      
  Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))      
  End      
  END)   
  end/ Sum(InvoiceDetail.Quantity) As Decimal(18,6)),       
 "Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.Quantity) As Decimal(18,6)),   
 "Net Value" = Sum(Amount),   
 "Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),    
 "Sales Tax Desc" = (select Tax_description from Tax where tax_code = items.Sale_Tax),  
 "Item MRP" = isnull(Items.MRP,0),   
 "SPBED" = IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0),   
 "Excise Duty" = IsNull(InvoiceDetail.ExciseDuty, 0), 'TaxComponents'  
 FROM InvoiceAbstract, InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand,  
 UOM As RUOM, ConversionTable, Customer   
 WHERE InvoiceAbstract.InvoiceID = @INVNO      
 AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
 AND InvoiceDetail.Product_Code = Items.Product_Code      
 AND Items.UOM *= UOM.UOM    
 AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code      
 AND Items.ManufacturerID *= Manufacturer.ManufacturerID       
 AND Items.CategoryID = ItemCategories.CategoryID      
 And Items.BrandID = Brand.BrandID      
 And Items.ReportingUOM *= RUOM.UOM      
 And Items.ConversionUnit *= ConversionTable.ConversionID      
 And InvoiceAbstract.CustomerID = Customer.CustomerID   
 GROUP BY InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,       
 InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'       
 + SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),      
 CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'      
 + SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),      
 --InvoiceDetail.MRP, InvoiceDetail.PTS, InvoiceDetail.PTR,       
 InvoiceDetail.SaleID, ItemCategories.Price_Option,     
 Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,      
 Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,      
 Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,       
 ConversionTable.ConversionUnit, InvoiceDetail.TaxID, InvoiceAbstract.TaxOnMRP,  
 Items.TaxSuffered, Items.Sale_Tax, Items.MRP,   
 InvoiceDetail.SalePriceBeforeExciseAmount,  
 InvoiceDetail.ExciseDuty  
 Order By InvoiceDetail.Product_Code, InvoiceDetail.SalePrice Desc
