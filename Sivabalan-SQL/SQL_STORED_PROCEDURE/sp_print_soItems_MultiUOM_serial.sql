CREATE PROCEDURE [dbo].[sp_print_soItems_MultiUOM_serial] (@SONumber int)  
AS 
SELECT "Item Code" = Max(SODetail.Product_Code), "Item Name" = Max(ProductName), 
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(Max(SODetail.Product_Code), Sum(SODetail.Quantity)),
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  Max(SODetail.Product_Code) )),
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(Max(SODetail.Product_Code), Sum(SODetail.Quantity)),
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  Max(SODetail.Product_Code) )),
"UOMQuantity" = dbo.GetLastLevelUOMQty(Max(SODetail.Product_Code), Sum(SODetail.Quantity)),
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  Max(SODetail.Product_Code) )),  

"Sale Price" = Max(SalePrice),   
"Tax Applicable%" = Sum(ISNULL(SaleTax, 0) + ISNULL(TaxCode2, 0)),  
"Discount" = max(Discount), "UOM" = Max(UOM1.Description), "Pending" = Sum(Pending),   
"Tax Suffered%" = Sum(ISNULL(SODetail.TaxSuffered, 0)),  
  
"Amount" = 
case mAX(TaxOnMRP) 
when 1 then 
	Sum(
			(
					(Quantity * SalePrice)  -  (Quantity * SalePrice * Discount / 100) + 
				(
					(Quantity * SODetail.ECP)  * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100
				) + 
				(
					(Quantity * SODetail.ECP)  * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100
				) * dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0))
			)
		 / 100) 
else
	Sum(
			(
				(Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)
			) +  
			(
				(
					(
						(Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)
					) +   
					(
						(
							(Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)
						) * SODetail.TaxSuffered / 100
					)
				) * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)
			) / 100
		) +  

	(
		(
			(Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)
		) * SODetail.TaxSuffered / 100
	)
)
end , 
"Tax Applicable Amount" = 
case MAX(TaxOnMRP) 
when 1 then 
	Round(Sum(((Quantity * SODetail.ECP) + (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100)   
	* dbo.fn_get_TaxOnMRP((IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)),2)  
else
	Sum(((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100))   
	+ (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100))   
	* (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100))
end,  
"Tax Suffered Amount" =
case mAX(TaxOnMRP) 
when 1 then 
	Sum((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100)
else
	Sum((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100))
end,  
"Manufacturer Code" = Max(Manufacturer.ManufacturerCode),  
"Manufacturer Name" = Max(Manufacturer.Manufacturer_Name),  
"Brand" = Max(Brand.BrandName),   
"Category" = max(ItemCategories.Category_Name),  
"Conversion Unit" = mAX(ConversionTable.ConversionUnit),  
"Conversion Factor" = MAX(Items.ConversionFactor),  
"Reporting UOM" = mAX(RUOM.Description),  
"Reporting Unit" = Sum(Items.ReportingUnit),  
"Reporting Unit Qty" = Sum((Quantity / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End))),  
"Conversion Unit Qty" = Sum((Quantity * Items.ConversionFactor)),  
"Item Desc" = mAX(IsNull(Items.Description, N'')),  
"Item Gross Value" = Sum(Quantity * SalePrice),
"Invoice Gross Value" = Sum(IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0)),
"Total Tax Amount"=
case mAX(TaxOnMRP) 
when 1 then
	Sum(((Quantity * SODetail.ECP)  * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) + 
	((Quantity * SODetail.ECP)  * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) 
	* dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100) 
else
	Round(Sum((((SODetail.Quantity * SODetail.SalePrice) - ((SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100))
	*(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0))/100)),2)
end,
Max(SODetail.ECP)
FROM SOAbstract
Inner Join SODetail ON SOAbstract.SONumber=SODetail.SONumber
Inner Join Items ON SODetail.Product_Code = Items.Product_Code   
Inner Join Manufacturer ON Items.ManufacturerID = Manufacturer.ManufacturerID  
Inner Join ItemCategories ON Items.CategoryID = ItemCategories.CategoryID
Inner Join Brand ON Items.BrandID = Brand.BrandID  
Left Outer Join UOM As UOM1 ON Items.UOM = UOM1.UOM
Left Outer Join ConversionTable ON Items.ConversionUnit = ConversionTable.ConversionID  
Left Outer Join UOM As RUOM  ON Items.ReportingUOM = RUOM.UOM
WHERE SODetail.SONumber = @SONumber
Group by SODetail.Serial
Order by SODetail.Serial

