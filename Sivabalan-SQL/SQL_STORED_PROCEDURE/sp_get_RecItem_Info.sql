CREATE procedure [dbo].[sp_get_RecItem_Info] (@ItemID Int)  
As  
Select "Product_Code" = ItemsReceivedDetail.Product_Code,   
"ProductName" = ItemsReceivedDetail.ProductName,  
ItemsReceivedDetail.CreationDate,   
"Description" = ItemsReceivedDetail.Description,   
"CategoryID" = ItemCategories.CategoryID,   
"ManufacturerID" = Manufacturer.ManufacturerID,   
"BrandID" = Brand.BrandID, "UOM" = SUOM.UOM,  
"Purchase_Price" = ItemsReceivedDetail.PurchasePrice,   
"Sale_Price" = ItemsReceivedDetail.SalePrice,   
"Sale_Tax" = STax.Tax_Code,  
"MRP" = ItemsReceivedDetail.MRP, "Preferred_Vendor" = Null,   
"StockNorm" = ItemsReceivedDetail.StockNorm,   
"MinOrderQty" = ItemsReceivedDetail.MinOrderQty,   
"Track_Batches" = ItemsReceivedDetail.Track_Batches,   
"Opening_Stock" = Null, "Opening_Stock_Value" = Null, "SchemeID" = Null,  
"ConversionFactor" = ItemsReceivedDetail.ConversionFactor,   
"ConversionUnit" = ConversionTable.ConversionID, "Active" = ItemsReceivedDetail.Active, 0,   
"SaleID" = ItemsReceivedDetail.SaleID,   
"Company_Price" = ItemsReceivedDetail.CompanyPrice,   
"PTS" = ItemsReceivedDetail.PTS,  
"PTR" = ItemsReceivedDetail.PTR, "ECP" = ItemsReceivedDetail.ECP,   
"Purchased_At" = ItemsReceivedDetail.PurchasedAt,   
"Company_Margin" = ItemsReceivedDetail.CompanyMargin,   
"Stockist_Margin" = ItemsReceivedDetail.StockistMargin,   
"Retailer_Margin" = ItemsReceivedDetail.RetailerMargin,   
"TaxSuffered" = PTax.Tax_Code, "SoldAs" = ItemsReceivedDetail.SoldAs,  
"Alias" = ItemsReceivedDetail.ForumCode, "ReportingUOM" = RUOM.UOM,   
"ReportingUnit" = ItemsReceivedDetail.ReportingUnit,  
"TrackPKD" = ItemsReceivedDetail.TrackPKD,   
"Virtual_Track_Batches" = ItemsReceivedDetail.Virtual_Track_Batches,   
"SupplyingBranch" = Null, Null, Null,
"Case_UOM" = CUOM.UOM,  
"Case_Conversion" = ItemsReceivedDetail.Case_Conversion
  
From ItemsReceivedDetail, UOM as SUOM, UOM as RUOM, Tax as STax, Tax as PTax,  
ConversionTable, Brand, Manufacturer, ItemCategories, UOM as CUOM  
Where ItemsReceivedDetail.ID = @ItemID And  
ItemsReceivedDetail.CategoryName = ItemCategories.Category_Name And  
ItemsReceivedDetail.ManufacturerName = Manufacturer.Manufacturer_Name And  
ItemsReceivedDetail.BrandName = Brand.BrandName And  
ItemsReceivedDetail.ReportingUOM *= RUOM.Description And  
ItemsReceivedDetail.UOM *= SUOM.Description And  
ItemsReceivedDetail.Case_UOM *= CUOM.Description And
ItemsReceivedDetail.ConversionUnit *= ConversionTable.ConversionUnit And  
ItemsReceivedDetail.STDesc *= STax.Tax_Description And  
ItemsReceivedDetail.PTDesc *= PTax.Tax_Description
