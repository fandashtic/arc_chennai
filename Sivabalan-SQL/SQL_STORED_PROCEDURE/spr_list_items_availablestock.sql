CREATE procedure [dbo].[spr_list_items_availablestock](@Mfr nvarchar(2550),        
      @Division nvarchar(2550),@ShowItems nvarchar(2000), 
	  @ItemCode nvarchar(2550),@UOM Nvarchar(255))    
AS  
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )  
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )
if @Mfr='%'   
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer  
Else  
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)  
  
if @Division='%'  
   Insert into #tmpDiv select BrandName from Brand  
Else  
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)  

if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

If @ShowItems = 'Items With Stock'    
	Begin    
	If @UOM = 'Sales UOM'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = Cast(sum(Quantity) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Saleable Stock" = Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) +  N' ' + IsNull(UOM.Description,''),     
		"Free Stock" = Cast(Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Damage Stock" = Cast(Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(UOM.Description,'')    
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, UOM    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.UOM *= UOM.UOM And
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,UOM.Description    
		HAVING Sum(Batch_Products.Quantity) > 0 ORDER BY Items.Product_Code    
	Else If @UOM = 'Conversion Factor'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = Cast(IsNull(Items.ConversionFactor,1) * IsNull(sum(Quantity),0) as NVarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),     
		"Saleable Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar)+ N' ' + IsNull(ConversionTable.ConversionUnit,''),     
		"Free Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar)+ N' ' + IsNull(ConversionTable.ConversionUnit,''),     
		"Damage Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar)+ N' ' + IsNull(ConversionTable.ConversionUnit,'')    
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand,ConversionTable    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
		Items.ConversionUnit *= ConversionTable.ConversionID 
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.ConversionFactor,ConversionTable.ConversionUnit
		HAVING Sum(Batch_Products.Quantity) > 0 ORDER BY Items.Product_Code    
	Else If @UOM = 'Reporting UOM'	
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,IsNull(sum(Quantity),0)) + N' ' + IsNull(UOM.Description,''),     
		"Saleable Stock" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)) + N' ' + IsNull(UOM.Description,''),     
		"Free Stock" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)) + N' ' + IsNull(UOM.Description,''),     
		"Damage Stock" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End))+ N' ' + IsNull(UOM.Description,'')    
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, UOM
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.ReportingUOM *= UOM.UOM And
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,UOM.Description    
		HAVING Sum(Batch_Products.Quantity) > 0 ORDER BY Items.Product_Code    
	Else If @UOM = 'Case UOM'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,sum(Quantity)), 
		"Saleable Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)),     
		"Free Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)) ,          
		"Damage Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End))   
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand,UOM    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.Case_UOM*=UOM.UOM And
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name
		HAVING Sum(Batch_Products.Quantity) > 0 ORDER BY Items.Product_Code    
	End    
Else     
  Begin    
	If @UOM = 'Sales UOM'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = Cast(sum(Quantity) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Saleable Stock" = Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(UOM.Description,'') ,     
		"Free Stock" = Cast(Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Damage Stock" = Cast(Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(UOM.Description,'')   
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, UOM    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.UOM *= UOM.UOM And
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,UOM.Description    
		ORDER BY Items.Product_Code    
	Else If @UOM = 'Conversion Factor'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = Cast(IsNull(Items.ConversionFactor,1) * IsNull(sum(Quantity),0) as Nvarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),
		"Saleable Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as NVarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),     
		"Free Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),     
		"Damage Stock" = Cast(IsNull(Items.ConversionFactor,1) * Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End) as Nvarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,'')    
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, ConversionTable    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) And
		Items.ConversionUnit *= ConversionTable.ConversionID 
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.ConversionFactor, ConversionTable.ConversionUnit     
		ORDER BY Items.Product_Code    
	Else If @UOM = 'Reporting UOM'	
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code,sum(Quantity)) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Saleable Stock" = cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)) as NVarchar) + N' ' + IsNull(UOM.Description,''),     
		"Free Stock" = cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)) as Nvarchar) + N' ' + IsNull(UOM.Description,''),     
		"Damage Stock" = cast(dbo.sp_Get_ReportingUOMQty(Items.Product_Code,Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End)) as Nvarchar) + N' ' + IsNull(UOM.Description,'')   
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, UOM    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And  
		Items.ReportingUOM *= UOM.UOM And   
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name, UOM.Description    
		ORDER BY Items.Product_Code    
	Else If @UOM = 'Case UOM'
		SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
		"Category" = ItemCategories.Category_Name,    
		"Total Qty" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,IsNull(sum(Quantity),0)),     
		"Saleable Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)),
		"Free Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then IsNull(Quantity,0) Else 0 End)),
		"Damage Stock" = dbo.sp_Get_CaseUOMQty(Items.Product_Code,Sum(Case When IsNull(Damage, 0) > 0 Then IsNull(Quantity,0) Else 0 End))    
		FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand, UOM    
		WHERE  Items.CategoryID = ItemCategories.CategoryID And     
		Items.Case_UOM*=UOM.UOM And
		Items.Product_Code *= Batch_Products.Product_Code And    
		Items.Active = 1    
		And Items.ManufacturerID = Manufacturer.ManufacturerID And      
		Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And    
		Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
		Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
		Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name    
		ORDER BY Items.Product_Code    
  End     
Drop Table #tmpMfr  
Drop Table #tmpDiv
