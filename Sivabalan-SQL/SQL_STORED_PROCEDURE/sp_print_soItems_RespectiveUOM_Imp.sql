Create PROCEDURE sp_print_soItems_RespectiveUOM_Imp (@SONumber int)    
AS   
SELECT "Item Code" = SODetail.Product_Code, "Item Name" = ProductName,     
"Quantity" = SODetail.UOMQty, "UOM" = UOM1.Description, "Sale Price" = UOMPrice,     
"Tax Applicable%" = ISNULL(SaleTax, 0) + ISNULL(TaxCode2, 0),    
"Discount" = Discount, "Pending" = Pending,     
"Tax Suffered%" = ISNULL(SODetail.TaxSuffered, 0),    
"Amount" =   
case TaxOnMRP   
when 1 then   
 ((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +    
 ((  (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100  ) *  
    dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)  )/ 100  ) +    
 (  (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100  )  
else  
 ((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +    
 ((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +     
 (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)) * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100) +    
 (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)  
end,    
"Tax Applicable Amount" =   
case TaxOnMRP   
when 1 then   
 (  
  (  
   (  
    (Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)  
   )   +     
   (  
    (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100  
   )  
  )     
 * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)  
else  
 ((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100))     
 + (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100))     
 * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)  
end,    
"Tax Suffered Amount" =   
case TaxOnMRP  
when 1 then   
 ((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100)  
else  
 (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)  
end  
,  
"Manufacturer Code" = Manufacturer.ManufacturerCode,    
"Manufacturer Name" = Manufacturer.Manufacturer_Name,    
"Brand" = Brand.BrandName,     
"Category" = ItemCategories.Category_Name,    
"Conversion Unit" = ConversionTable.ConversionUnit,    
"Conversion Factor" = Items.ConversionFactor,    
"Reporting UOM" = RUOM.Description,    
"Reporting Unit" = Items.ReportingUnit,    
"Reporting Unit Qty" = (Quantity / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),    
"Conversion Unit Qty" = (Quantity * Items.ConversionFactor),    
"Item Desc" = IsNull(Items.Description, N''),  
"Item Gross Value" = Quantity * SalePrice,  
"Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0),  
"Total Tax Amount"=  
case TaxOnMRP   
when 1 then   
 Round(  
 (  
  (  
   (SODetail.Quantity * SODetail.ECP)   
  )  
  *dbo.fn_get_TaxOnMRP(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0))/100),2)  
else  
 Round((((SODetail.Quantity * SODetail.SalePrice) - ((SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100))  
 *(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0))/100),2)  
end,  
SODetail.ECP,  
"Gross Amount Total" = (case TaxOnMRP   
when 1 then   
 (  
  (  
   (  
    (Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)  
   )   +     
   (  
    (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100  
   )  
  )     
 * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)  
else  
 ((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100))     
 + (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100))     
 * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)  
end) + (Quantity * SalePrice)   

  
FROM SOAbstract
Inner Join SODetail On SOdetail.SoNumber=Soabstract.SoNumber  
Inner Join Items On SODetail.Product_Code = Items.Product_Code     
Left Outer Join  UOM As UOM1 On  SODetail.UOM = UOM1.UOM    
Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID    
Inner Join  Brand On Items.BrandID = Brand.BrandID    
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID    
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID    
Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM        
WHERE SODetail.SONumber = @SONumber     
order by SODetail.Product_Code  
