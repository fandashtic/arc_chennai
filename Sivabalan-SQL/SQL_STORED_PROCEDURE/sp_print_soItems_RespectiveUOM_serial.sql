CREATE procedure [dbo].[sp_print_soItems_RespectiveUOM_serial] (@SONumber int)  
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
	((		(Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100		) *
		 	dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)		)/ 100		) +  
	(		(Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100		)
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
SODetail.ECP


FROM SOAbstract, SODetail, Items, UOM As UOM1, Manufacturer, Brand, ItemCategories, ConversionTable,   
UOM As RUOM  
WHERE SODetail.SONumber = @SONumber   
And SOdetail.SoNumber=Soabstract.SoNumber
AND SODetail.Product_Code = Items.Product_Code   
AND SODetail.UOM *= UOM1.UOM  
And Items.ReportingUOM *= RUOM.UOM  
AND Items.ManufacturerID = Manufacturer.ManufacturerID  
AND Items.CategoryID = ItemCategories.CategoryID  
AND Items.BrandID = Brand.BrandID  
AND Items.ConversionUnit *= ConversionTable.ConversionID  
order by SODetail.Serial
