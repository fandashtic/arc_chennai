CREATE procedure [dbo].[spr_list_items_availablestock_MUOM](@Mfr nvarchar(2550),          
      												@Division nvarchar(2550),
													@ShowItems nvarchar(2000), 
													@UOM nvarchar(50), 
													@ItemCode nvarchar(2550))      
AS    
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @Mfr=N'%'     
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer    
Else    
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)    
    
if @Division=N'%'    
   Insert into #tmpDiv select BrandName from Brand    
Else    
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)    
  
if @ItemCode = N'%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

If IsNull(@UOM,N'') = N'' or @UOM = N'%'  or  @UOM = N'Base UOM'
 Set @UOM = N'Sales UOM'  
If @ShowItems = N'Items With Stock'      
  Begin      
  SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,       
  "Category" = ItemCategories.Category_Name,      
  "Total Qty" = Case @UOM When N'Sales UOM' Then sum(Quantity) Else dbo.sp_Get_ReportingQty( sum(Quantity),  
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End,       
  "Saleable Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End)
,   
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End,       
  "Free Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),   
 
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End,       
  "Damage Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End),
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End
  FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand      
  WHERE  Items.CategoryID = ItemCategories.CategoryID And       
  Items.Product_Code *= Batch_Products.Product_Code And      
  Items.Active = 1      
  And Items.ManufacturerID = Manufacturer.ManufacturerID And        
  Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And      
  Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
  Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.UOM1_Conversion,Items.UOM2_Conversion      
  HAVING Sum(Batch_Products.Quantity) > 0 ORDER BY Items.Product_Code      
  End      
Else       
  Begin      
  SELECT Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,       
  "Category" = ItemCategories.Category_Name,      
  "Total Qty" = Case @UOM When N'Sales UOM' Then sum(Quantity) Else dbo.sp_Get_ReportingQty( sum(Quantity),   
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End, 
  "Saleable Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End)
,
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End,       
  "Free Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End),   
 
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End,       
  "Damage Stock" = Case @UOM When N'Sales UOM' Then Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End)  Else dbo.sp_Get_ReportingQty( Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End),   
 (Case @UOM --When 'Sales UOM' Then 1  
 When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
 When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
 End)) End
  FROM Items, ItemCategories, Batch_Products,Manufacturer, Brand      
  WHERE  Items.CategoryID = ItemCategories.CategoryID And       
  Items.Product_Code *= Batch_Products.Product_Code And      
  Items.Active = 1      
  And Items.ManufacturerID = Manufacturer.ManufacturerID And        
  Manufacturer.Manufacturer_Name in (select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And      
  Items.BrandID = Brand.BrandID And Brand.BrandName in (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And
  Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  Group By Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.UOM1_Conversion,Items.UOM2_Conversion      
  ORDER BY Items.Product_Code      
  End       
Drop Table #tmpMfr    
Drop Table #tmpDiv
