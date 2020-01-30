CREATE procedure [dbo].[sp_print_SOItems_Ascending](@SONumber int)  
AS  
	SELECT "Item Code" = SODetail.Product_Code,   
		"Item Name" = ProductName,   
		"Quantity" = sum(Quantity),   
		"Sale Price" = SalePrice,   
		"Tax Applicable%" = ISNULL(SaleTax, 0) + ISNULL(TaxCode2, 0),  
		"Discount" = Discount,   
		"UOM" = UOM1.Description,   
		"Pending" = sum(Pending),   
		"Tax Suffered%" = ISNULL(SODetail.TaxSuffered, 0),  
		"Amount" = CASE IsNull(TaxOnMRP,0)  
		WHEN 1 THEN  
			 Round(Sum((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100) +  
			 ((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) +  
			 ((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100) *  
			 dbo.fn_get_TaxOnMRP(IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100),2)  
		ELSE  
			 sum((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +  
			 ((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) +   
			 (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)) * (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100) +  
			 (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)  
		END,  
		"Tax Applicable Amount" = CASE IsNull(TaxOnMRP,0)  
		WHEN 1 THEN  
			Round(Sum(((Quantity * SODetail.ECP) + (Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100)   
			* dbo.fn_get_TaxOnMRP((IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)),2)  
		ELSE  
			((((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100))   
			+ (((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100))   
			* (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)  
		END,  
		"Tax Suffered Amount" = CASE TaxOnMRP  
		WHEN 1 THEN  
			Sum(Round((Quantity * SODetail.ECP) * dbo.fn_get_TaxOnMRP(SODetail.TaxSuffered) / 100,2))  
		ELSE  
			(((Quantity * SalePrice) - (Quantity * SalePrice * Discount / 100)) * SODetail.TaxSuffered / 100)  
		END,  
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
		"Description" = Items.Description,   
		"Item Gross Value" = Quantity * SalePrice,  
		"Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0),  
		"Total Tax Amount"= CASE IsNull(TaxOnMRP,0)  
		WHEN 1 THEN  
			Round(Sum(((SODetail.Quantity * SODetail.ECP) + (SODetail.Quantity * SODetail.ECP) 
			* dbo.fn_get_TaxOnMRP(IsNull(SODetail.TaxSuffered,0)) / 100)       
			* dbo.fn_get_TaxOnMRP(Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0)) / 100),2)
		ELSE  
			Round((((SODetail.Quantity * SODetail.SalePrice) - ((SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100))  
			*(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0))/100),2)  
		END,
		"Batch"=SoDetail.Batch_Number,
		"PriceOption" = ItemCategories.Price_Option,"TrackBatch"= Items.Track_Batches,
		"VAT" = isnull(sodetail.vat,0),
		"TaxApplicableon" = isnull(sodetail.taxapplicableon,0),
		"TaxPartOff" = isnull(sodetail.taxpartoff,0),
		"TaxSuffApplicableon" = isnull(sodetail.taxSuffapplicableon,0),
		"TaxsuffPartOff" = isnull(sodetail.taxsuffpartoff,0)
		FROM SODetail, Items, UOM As UOM1, Manufacturer, Brand, ItemCategories, ConversionTable, SOAbstract,   
		UOM As RUOM WHERE SODetail.SONumber = @SONumber   
		AND SODetail.Product_Code = Items.Product_Code   
		And SOAbstract.SONumber = SODetail.SONumber   
		AND Items.UOM *= UOM1.UOM  
		And Items.ReportingUOM *= RUOM.UOM  
		AND Items.ManufacturerID = Manufacturer.ManufacturerID  
		AND Items.CategoryID = ItemCategories.CategoryID  
		AND Items.BrandID = Brand.BrandID  
		AND Items.ConversionUnit *= ConversionTable.ConversionID  
		group by SODetail.Product_Code, ProductName, Quantity, SalePrice, SaleTax, TaxCode2,   
		Discount, UOM1.Description, Pending, SODetail.TaxSuffered, Quantity, SalePrice,   
		Manufacturer.manufacturercode, Manufacturer.Manufacturer_Name, Brand.BrandName,   
		ItemCategories.Category_Name, ConversionTable.ConversionUnit, Items.ConversionFactor,   
		RUOM.Description, Items.ReportingUnit, Items.ReportingUnit, Items.ReportingUnit,   
		Items.ConversionFactor, Items.Description, Items.Description, TaxOnMRP ,SODetail.Batch_Number,Items.Track_Batches,ItemCategories.Price_Option,
		sodetail.vat,sodetail.taxapplicableon,sodetail.taxpartoff,sodetail.taxSuffapplicableon,
		sodetail.taxsuffpartoff
