CREATE procedure [dbo].[sp_get_RecItem_Info_FMCG] (@ItemID Int)  
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
ItemsReceivedDetail.Track_Batches, Null, Null, Null,  
"ConversionFactor" = ItemsReceivedDetail.ConversionFactor,   
"ConversionUnit" = ConversionTable.ConversionID, "Active" = ItemsReceivedDetail.Active, 0,   
"SaleID" = ItemsReceivedDetail.SaleID, "TaxSuffered" = PTax.Tax_Code,   
"SoldAs" = ItemsReceivedDetail.SoldAs,  
"Alias" = ItemsReceivedDetail.ForumCode,   
"ReportingUOM" = RUOM.UOM,   
"ReportingUnit" = ItemsReceivedDetail.ReportingUnit,  
"TrackPKD" = ItemsReceivedDetail.TrackPKD, ItemsReceivedDetail.Virtual_Track_Batches ,   
"SupplyingBranch" = Null, Null, Null, 
"CaseUOM" = IsNull(CUOM.UOM,''),
"CaseConversion" = ItemsReceivedDetail.Case_Conversion
From ItemsReceivedDetail, UOM as SUOM, UOM as RUOM, Tax as STax, Tax as PTax,  
ConversionTable, Brand, Manufacturer, ItemCategories, CUOM as UOM  
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
