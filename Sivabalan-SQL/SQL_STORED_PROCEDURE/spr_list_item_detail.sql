Create PROCEDURE spr_list_item_detail(@PRODUCT_CODE nvarchar(15))        
AS        
  Begin
	Declare @PRICETOSTOCKIST As NVarchar(50)  
	Declare @PRICETORETAILER As NVarchar(50)  
	Declare @YES As NVarchar(50)  
	Declare @NO As NVarchar(50)  
	  
	Set @PRICETOSTOCKIST = dbo.LookupDictionaryItem(N'Price to Stockist', Default)  
	Set @PRICETORETAILER = dbo.LookupDictionaryItem(N'Price to Retailer', Default)  
	Set @YES = dbo.LookupDictionaryItem(N'Yes', Default)  
	Set @NO = dbo.LookupDictionaryItem(N'No', Default)  
	  
	SELECT Product_Code, "Preferred Vendor" = Vendors.Vendor_Name,         
	 "Manufacturer" = Manufacturer.Manufacturer_Name, "Division" = Brand.BrandName,        
	 "UOM" = UOM.Description,         
	 "Reporting UOM" = (select UOM.Description from Uom where UOm = Items.ReportingUOM),        
	 "Reporting Unit" = ReportingUnit,        
	 "Conversion Factor" = (Select ConversionTable.ConversionUnit From ConversionTable Where ConversionId = Items.ConversionUnit),        
	 "Conversion Unit" = ConversionFactor,          
	 "Purchased At" = CASE Items.Purchased_At        
	 WHEN 1 THEN @PRICETOSTOCKIST  
	 WHEN 2 THEN @PRICETORETAILER       
	 END,        
	 "PFM" = isnull(Items.PFM, 0), -- Add New Columd For FITC-3068
	 "PTS" = ISNULL(Items.PTS, 0),        
	 "PTR" = ISNULL(Items.PTR, 0),        
	 "ECP" = ISNULL(Items.ECP, 0),        
	 "Special Price" = ISNULL(Items.Company_Price, 0),        
	 "Purchase Price" = ISNULL(Items.Purchase_Price, 0),         
--	 "MRP" = ISNULL(MRP, 0),         
	 "MRP Per Pack" = ISNULL(Items.MRPPerPack, 0),         
	 "Sale Tax" = Tax.Tax_Description,     
	 "Case UOM" = ISNULL(CCUOM.Description,''),  
	 "Case Conversion" = Items.Case_Conversion,  
	 "User Defined Code"=IsNull(UserDefinedCode,''),   
	 "StockNorm" = ISNULL(StockNorm, 0),         
	 "MOQ" = ISNULL(MinOrderQty, 0),        
	 "Track Batches" = CASE Items.Track_Batches        
	 WHEN 0 THEN @NO      
	 WHEN 1 THEN @YES    
	 END,        
	 "Tax Suffered" = b.Tax_Description   
	,"Active" = Case When isnull(Items.Active,0) = 1 Then 'Yes' Else 'No' End 
	FROM Items
	Left Outer Join Vendors On Items.Preferred_Vendor = Vendors.VendorID        
	Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID
	Left Outer Join Brand On Items.BrandID = Brand.BrandID        
	Left Outer Join  UOM On Items.UOM = UOM.UOM 
	Left Outer Join Tax On Items.Sale_Tax = Tax.Tax_Code 
	Left Outer Join Tax b On Items.TaxSuffered = b.Tax_Code  
	Left Outer Join UOM CCUOM On Items.Case_UOM = CCUOM.UOM  
	WHERE   Product_Code = @PRODUCT_CODE        
	 
End
