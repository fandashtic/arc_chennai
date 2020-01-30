CREATE procedure [dbo].[sp_print_RetInvItems_RespectiveUOM_Pidilite](@INVNO INT)          
AS    
         
SELECT "Item Code" = InvoiceDetail.Product_Code, "Item Name" = Items.ProductName,           
 "Batch" = InvoiceDetail.Batch_Number, "Quantity" = Sum(InvoiceDetail.UOMQty),          
 "UOM" = UOM.Description,  
  "Free Qty" = (Select Sum(InvDet.Quantity)   
    From InvoiceDetail InvDet Where InvDet.InvoiceID = @INVNO  
    And InvDet.Product_Code = InvoiceDetail.Product_Code and InvDet.FlagWord = 1   
                And InvDet.uom = InvoiceDetail.uom ),            
 "Sale Price" = Case InvoiceDetail.UOMPrice        
  When 0 then          
  N'Free'          
  Else          
  Cast(InvoiceDetail.UOMPrice as nvarchar)          
  End,           
 "Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),           
 "Discount%" = Max(InvoiceDetail.DiscountPercentage),           
 "Discount Value" = Max(InvoiceDetail.DiscountValue),           
 "Amount" = sum(InvoiceDetail.Amount),          
 "Total Savings - Incl Discount" = (Sum(InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option   
  WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -       
  ((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -        
  ((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (MAX(InvoiceDetail.DiscountPercentage) / 100))),         
 "Expiry" = CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'          
  + SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),          
  --"MRP" = InvoiceDetail.MRP, "PTS" = InvoiceDetail.PTS, "PTR" = InvoiceDetail.PTR,          
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
  WHEN InvoiceDetail.SaleID = 0 AND Max(InvoiceDetail.STPayable) <> 0 THEN N'F'          
  ELSE N' '          
  END,          
 "Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),          
 "Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,          
 "Category" = ItemCategories.Category_Name,          
 "Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice          
  When 0 then          
  NULL          
  Else          
  Cast(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)          
  End,          
 "Amount Before Tax" = Sum(InvoiceDetail.Amount) - (Max(InvoiceDetail.STPayable) + Max(InvoiceDetail.CSTPayable)),          
 "Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),          
 "Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),          
 "Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),          
 "Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),          
 "Conversion Unit Qty" = Sum(InvoiceDetail.Quantity) * Items.ConversionFactor,          
 "Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),          
 "Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),          
 "Mfr Name" = Manufacturer.Manufacturer_Name,          
 "Divison" = Brand.BrandName,          
 "Tax Applicable Value" = IsNull(Max(InvoiceDetail.STPayable), 0) + IsNull(Max(InvoiceDetail.CSTPayable), 0),          
 "Tax Suffered Value" = isnull(sum(invoicedetail.taxsuffamount),0),  
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
  NULL          
  Else          
  Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +       
  (SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option   
  WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)  
  * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6)       
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
  END)   
  else --when TaxOnMRP = 0  
  (case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = @INVNO)          
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
  END)   
  end  
  / CASE WHEN Sum(InvoiceDetail.UOMQty) = 0 THEN 1 ELSE Sum(InvoiceDetail.UOMQty) END As Decimal(18,6)),         
 "Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.UOMQty) As Decimal(18,6)),   
 "Net Value" = Sum(Amount),   
 "Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),  
 "Sales Tax Desc" = (select Tax_description from Tax where tax_code = items.Sale_Tax),  
 "Item MRP" = isnull(Items.MRP,0),   
 "SPBED" = IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0),   
 "Excise Duty" = IsNull(InvoiceDetail.ExciseDuty, 0) ,"TaxComponents" = N'TaxComponents'  Into #tmpInvoice  
 FROM InvoiceAbstract, InvoiceDetail, UOM, Items, Batch_Products, Manufacturer, ItemCategories, Brand,          
 UOM As RUOM, ConversionTable          
 WHERE InvoiceAbstract.InvoiceID = @INVNO   
 AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 AND InvoiceDetail.Product_Code = Items.Product_Code          
 AND InvoiceDetail.UOM *= UOM.UOM          
 AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code          
 AND Items.ManufacturerID *= Manufacturer.ManufacturerID           
 AND Items.CategoryID = ItemCategories.CategoryID          
 And Items.BrandID = Brand.BrandID          
 And Items.ReportingUOM *= RUOM.UOM          
 And Items.ConversionUnit *= ConversionTable.ConversionID  
 --And InvoiceDetail.FlagWord = 0  
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
 ConversionTable.ConversionUnit, UOM.Description, InvoiceDetail.UOMPrice, InvoiceAbstract.TaxOnMRP,  
 Items.TaxSuffered, Items.Sale_Tax, Items.MRP, InvoiceDetail.TaxID,  
 InvoiceDetail.SalePriceBeforeExciseAmount,  
 InvoiceDetail.ExciseDuty,InvoiceDetail.uom

Delete From #tmpInvoice  Where [Sale Price]=N'Free' and   
IsNull((Select 1 From #tmpInvoice tmpA Where tmpA.[Sale Price] not like N'Free' and   
 tmpA.Uom= #tmpInvoice.UOM and tmpa.[item code] = #tmpinvoice.[item code]),0) = 1  
  
Update #tmpInvoice Set Quantity = Null ,[Sale Price]=Null Where [Sale Price]=N'Free'          
  
Select * From #tmpInvoice
