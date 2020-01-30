CREATE procedure [dbo].[sp_print_soItems] (@SONumber int)  
AS  
SELECT "Item Code" = max(SODetail.Product_Code),   
"Item Name" = max(ProductName),   
"Quantity" = Sum(Quantity),   
"Sale Price" = Max(SalePrice),   
"Tax Applicable%" = Max(ISNULL(SaleTax, 0)) + Max(ISNULL(TaxCode2, 0)),  
"Discount" = Max(Discount),   
"UOM" = Max(UOM1.Description),   
"Pending" = sum(Pending),   
"Tax Suffered%" = mAX(ISNULL(SODetail.TaxSuffered, 0)),  
"Amount" = CASE Max(IsNull(TaxOnMRP,0))  
WHEN 1 THEN  
	 Round(Sum((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100) +  
	 ((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) +  
	 ((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) *  
	 dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100),2)  
ELSE  
	 sum(
			(Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)
		) +  
	 	(
			(
				(
					(Sum(Quantity) * Max(SalePrice)) - (Sum(Quantity) * max(SalePrice) * Max(Discount) / 100)
				) +   
	 			(
					(
						(Sum(Quantity) * Max(SalePrice)) - (Sum(Quantity) * Max(SalePrice) * Max(Discount) / 100)
					) * max(SODetail.TaxSuffered) / 100
				)
			)
			 * (Max(IsNull(SaleTax, 0)) + Max(IsNull(TaxCode2, 0))) / 100
		) +  
	 	(
			(
				(Sum(Quantity) * Max(SalePrice)) - (Sum(Quantity) * max(SalePrice) * Max(Discount) / 100)
			) * Max(SODetail.TaxSuffered) / 100
		)  
END,

"Tax Applicable Amount" = CASE mAX(IsNull(TaxOnMRP,0))  
WHEN 1 THEN  
Round(
	Sum(
			(
				(Quantity * SODetail.ECP) + (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100
			)   
		* dbo.fn_get_TaxOnMRP((IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)
		)
	,2)  
ELSE  
(
	(
		(
			(sUM(Quantity) * mAX(SalePrice)) - (sUM(Quantity) * mAX(SalePrice) * MAX(Discount) / 100))   
+ (((sUM(Quantity) * MAX(SalePrice)) - (sUM(Quantity) * mAX(SalePrice) * mAX(Discount) / 100)) * mAX(SODetail.TaxSuffered) / 100))   
* (mAX(IsNull(SaleTax, 0)) + mAX(IsNull(TaxCode2, 0))) / 100)  
END, 
"Tax Suffered Amount" = CASE mAX(TaxOnMRP)  
WHEN 1 THEN  
Sum(
	Round(
			(Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100
		,2)
	)  
ELSE  
(
	(
		(sUM(Quantity) * mAX(SalePrice)) - (sUM(Quantity) * MAX(SalePrice) *mAX( Discount) / 100)) * MAX(SODetail.TaxSuffered) / 100)  
END, 
"Manufacturer Code" = Max(Manufacturer.ManufacturerCode),  
"Manufacturer Name" = Max(Manufacturer.Manufacturer_Name),  
"Brand" = Max(Brand.BrandName),   
"Category" = Max(ItemCategories.Category_Name),  
"Conversion Unit" = Max(ConversionTable.ConversionUnit),  
"Conversion Factor" = Max(Items.ConversionFactor),  
"Reporting UOM" = Max(RUOM.Description),  
"Reporting Unit" =  Max(Items.ReportingUnit),  
"Reporting Unit Qty" = (Sum(Quantity) / (Case IsNull(max(Items.ReportingUnit), 0) When 0 Then 1 Else max(Items.ReportingUnit) End)),  
"Conversion Unit Qty" = (Sum(Quantity) * Max(Items.ConversionFactor)),  
"Item Desc" = Max(IsNull(Items.Description, N'')),  
"Description" = Max(Items.Description),   
"Item Gross Value" = Sum(Quantity) * Max(SalePrice),  
"Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, Max(SODetail.Product_Code)),0),  
"Total Tax Amount"= CASE mAX(IsNull(TaxOnMRP,0))  
WHEN 1 THEN  
Round(
	Sum(
			(
				(SODetail.Quantity * SODetail.ECP) + (SODetail.Quantity * SODetail.ECP) 
				* dbo.fn_get_TaxOnMRP(IsNull(SODetail.TaxSuffered,0)
			) / 100
		)       
			* dbo.fn_get_TaxOnMRP(Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0)
		) / 100
		),2)
ELSE  
Round(
		(
			(
				(sUM(SODetail.Quantity) * mAX(SODetail.SalePrice)) - 
				(
					(sUM(SODetail.Quantity) *mAX(SODetail.SalePrice)) * mAX(SODetail.Discount) / 100)
				)  
				*(mAX(IsNull(SODetail.TaxSuffered,0)) + MAX(Isnull(SODetail.SaleTax,0)) + MAX(Isnull(SODetail.TaxCode2,0)))
			/100)
	,2)  
END,
"Batch"=Max(SoDetail.Batch_Number),
"PriceOption" = max(ItemCategories.Price_Option),"TrackBatch"= Max(Items.Track_Batches),
"VAT" = Max(isnull(sodetail.vat,0)),
"TaxApplicableon" = Max(isnull(sodetail.taxapplicableon,0)),
"TaxPartOff" = Max(isnull(sodetail.taxpartoff,0)),
"TaxSuffApplicableon" = Max(isnull(sodetail.taxSuffapplicableon,0)),
"TaxsuffPartOff" = Max(isnull(sodetail.taxsuffpartoff,0))
FROM SODetail, Items, UOM As UOM1, Manufacturer, Brand, ItemCategories, ConversionTable, SOAbstract,   
UOM As RUOM 
WHERE SODetail.SONumber = @SONumber   
AND SODetail.Product_Code = Items.Product_Code   
And SOAbstract.SONumber = SODetail.SONumber   
AND Items.UOM *= UOM1.UOM  
And Items.ReportingUOM *= RUOM.UOM  
AND Items.ManufacturerID = Manufacturer.ManufacturerID  
AND Items.CategoryID = ItemCategories.CategoryID  
AND Items.BrandID = Brand.BrandID  
AND Items.ConversionUnit *= ConversionTable.ConversionID  
group by SODETAIL.Serial
order by SODETAIL.Serial
