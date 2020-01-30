Create Procedure mERP_spr_ItemMasterExport 
As
Begin 
	Select Items.Product_Code as [Item Code], Items.Product_Code as [Item Code],
	Items.ProductName as [Item Name],
	Items.Description,
	ItemCategories.Category_Name as [Category],
	Manufacturer.Manufacturer_name as [Manufacturer],
	Brand.BrandName as [Brand],
	UOM.Description as [Uom],
	STax.Percentage as [Sale Tax],
	--Items.MRP,
	isnull(Items.MRPPerPack,0) as [MRP Per Pack],
	Vendors.VendorID as [Preferred Vendor],
	Items.StockNorm as [Stock Norm],
	Items.MinOrderQty as [Lot Size],
	CASE Items.Track_Batches 
	WHEN 1 THEN 'Yes'
	WHEN 0 THEN 'No' 
	END As "Batch Tracked",
	CASE Items.ConversionFactor
	WHEN 0 Then null
	ELSE Items.ConversionFactor 
	END
	As "Conversion Factor",
	ConversionTable.ConversionUnit As "Conversion Unit",
	case Items.SaleID 
	When 1 then 'First Sale'
	when 2 then 'Second Sale'
	End
	As "First Sale/Second Sale",
	Items.Company_Price As "Special Price",
	"PFM" = isnull(Items.PFM, 0) ,
	Items.PTS As "PTS",
	Items.PTR As "PTR",
	Items.ECP As "ECP",
	case Items.Purchased_At 
	when 1 then 'Price to Stockist'
	when 2 then 'Price to Retailer'
	End As "Purchased At",
	UOM1.Description as [Uom 1],
	Items.UOM1_Conversion as [UOM 1_Conversion],
	UOM2.Description as [Uom 2],
	Items.UOM2_Conversion as [UOM 2_Conversion],
	Case (IsNull(DefaultUOM,0) / 8) & 7 
		When 7 Then Uom.Description
			When 0 Then Uom.Description
			When 1 Then Uom1.Description
			When 2 Then Uom2.Description
			Else N'Multiple' End  as [Purchase Default Uom],
	Case IsNull(DefaultUOM,0) & 7 
		When 7 Then Uom.Description
			When 0 Then Uom.Description
			When 1 Then Uom1.Description
			When 2 Then Uom2.Description
			Else N'Multiple' End as [Sales Default Uom],
	Case IsNull(PriceatUOMlevel,0)
		When 0 then Uom.Description
		Else PratUOM.Description End as [PriceatUOMlevel],
	PTax.Percentage as [Tax Suffered],
	Items.SoldAs as [Sold As],
	Items.Alias as Alias,
	RUom.Description as "Reporting Uom",
	Items.ReportingUnit As "Reporting Unit",
	CASE Items.TrackPKD 
	WHEN 1 THEN 'Yes'
	WHEN 0 THEN 'No' 
	END As "PKD Tracked",
	0 as [Sale_Tax CST],
	0 as [Tax Suffered CST],
	'No' as [Tax Inclusive],
	0 as [Adhoc Amount],
	Items.ECP as [Tax Inclusive Rate],
	'Yes' as Vat,
	'No' as CollectTaxSuffered,
	'SalePrice' as ST_LSTApplicableOn,
	100 as ST_LSTPartOff,
	'SalePrice' as ST_CSTApplicableOn,
	100 as ST_CSTPartOff,
	'SalePrice' as TF_LSTApplicableOn,
	100 as TF_LSTPartOff,
	'SalePrice' as TF_CSTApplicableOn,
	100 as TF_CSTPartOff,
	CASE Isnull(ASL,0)When 0 Then 'No' Else 'Yes' End as HealthCare_Item 
	from Items
	Inner Join Itemcategories On Items.CategoryID = Itemcategories.CategoryID
	Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID 
	Inner Join Brand On Items.BrandID = Brand.BrandID
	Left Outer Join Uom On Items.Uom = Uom.Uom
	Left Outer Join Uom Ruom On Items.ReportingUom = Ruom.Uom
	Left Outer Join Uom Uom1 On  Items.Uom1 = Uom1.Uom 
	Left Outer Join Uom Uom2 On Items.Uom2 = Uom2.Uom
	Left Outer Join Uom PratUOM On Items.PriceatUomLevel = Pratuom.uom
	Left Outer Join  Tax STax On Items.Sale_Tax = Stax.tax_code
	Left Outer Join Tax PTax On Items.TaxSuffered = Ptax.tax_code
	Left Outer Join ConversionTable On  Items.ConversionUnit = ConversionTable.ConversionID
	Left Outer Join Vendors On Items.Preferred_Vendor = Vendors.VendorID
	Order by Items.ProductName

End
