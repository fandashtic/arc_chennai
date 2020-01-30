CREATE Procedure sp_Items_Created (@Criteria int,
				   @FromDate Datetime,
				   @ToDate Datetime,
				   @MFromDate Datetime,
				   @MToDate Datetime)
As
If (@Criteria & 3) = 3 
Begin
	Select Items.Alias, 
	Items.Product_Code, 
	Items.ProductName, 
	ItemCategories.Category_Name, 
	Manufacturer.Manufacturer_Name, 
	Brand.BrandName, 
	Items.PTS, 
	Items.PTR, 
	Items.ECP,
	dbo.StripDateFromTime(Items.CreationDate),
	dbo.StripDateFromTime(Items.ModifiedDate)
	From Items, ItemCategories, Manufacturer, Brand 
	Where Items.CategoryID = ItemCategories.CategoryID And 
	Items.ManufacturerID = Manufacturer.ManufacturerID And 
	Items.BrandID = Brand.BrandID And 
	Items.Active = 1 And 
	IsNull(Items.Alias, N'') <> N'' And 
	(Items.CreationDate Between @FromDate And @ToDate Or
	Items.ModifiedDate Between @MFromDate And @MToDate)
End
Else If (@Criteria & 3) = 1
Begin
	Select Items.Alias, 
	Items.Product_Code, 
	Items.ProductName, 
	ItemCategories.Category_Name, 
	Manufacturer.Manufacturer_Name, 
	Brand.BrandName, 
	Items.PTS, 
	Items.PTR, 
	Items.ECP,
	dbo.StripDateFromTime(Items.CreationDate),
	dbo.StripDateFromTime(Items.ModifiedDate)
	From Items, ItemCategories, Manufacturer, Brand 
	Where Items.CategoryID = ItemCategories.CategoryID And 
	Items.ManufacturerID = Manufacturer.ManufacturerID And 
	Items.BrandID = Brand.BrandID And 
	Items.Active = 1 And 
	IsNull(Items.Alias, N'') <> N'' And 
	Items.CreationDate Between @FromDate And @ToDate
End
Else If (@Criteria & 3) = 2
Begin
	Select Items.Alias, 
	Items.Product_Code, 
	Items.ProductName, 
	ItemCategories.Category_Name, 
	Manufacturer.Manufacturer_Name, 
	Brand.BrandName, 
	Items.PTS, 
	Items.PTR, 
	Items.ECP,
	dbo.StripDateFromTime(Items.CreationDate),
	dbo.StripDateFromTime(Items.ModifiedDate)
	From Items, ItemCategories, Manufacturer, Brand 
	Where Items.CategoryID = ItemCategories.CategoryID And 
	Items.ManufacturerID = Manufacturer.ManufacturerID And 
	Items.BrandID = Brand.BrandID And 
	Items.Active = 1 And 
	IsNull(Items.Alias, N'') <> N'' And 
	Items.ModifiedDate Between @MFromDate And @MToDate
End
