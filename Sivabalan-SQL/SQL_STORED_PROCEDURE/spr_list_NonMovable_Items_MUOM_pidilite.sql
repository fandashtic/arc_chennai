CREATE procedure spr_list_NonMovable_Items_MUOM_pidilite(@ShowItems nvarchar(255),   
@FromDate datetime, @ToDate datetime , @UOM nvarchar(50), @ItemCode nVarChar(2550))    
as    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @ItemCode = N'%'    
Insert InTo #tmpProd Select Product_code From Items    
Else    
Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)    
If IsNull(@UOM,N'') = N'' or @UOM = N'%'   
Set @UOM = N'Sales UOM'        
if @ShowItems = N'Items With Stock'  
begin  
select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
"Description" = Items.Description, "Category" = ItemCategories.Category_Name,     
"Last Sale Date" = (select Max(InvoiceAbstract.InvoiceDate)    
from InvoiceAbstract, InvoiceDetail    
where InvoiceAbstract.InvoiceDate < @FromDate and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceType in (1,2,3) and    
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
InvoiceDetail.Product_Code = Items.Product_Code),     
"Saleable Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) *  ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Damaged Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,   
"Free Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Maximum Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) 
When N'Conversion Factor' Then ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Total Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products    
where Batch_Products.Product_Code = Items.Product_Code), 0) as Decimal(18,6))  
From Items, ItemCategories, Batch_Products    
where     
Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )    
from InvoiceDetail, InvoiceAbstract    
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceType in (1,2,3)) And    
Items.CategoryID = ItemCategories.CategoryID And   
Batch_Products.Product_Code = Items.Product_Code   
AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
group by Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.UOM1_Conversion,Items.UOM2_Conversion,Items.ConversionFactor,Items.ReportingUnit  
having sum(Batch_Products.Quantity) > 0  
end  
else   
begin  
select  Items.Product_Code, "Item Code" = Items.Product_Code, "Item Name" = Items.ProductName,     
"Description" = Items.Description, "Category" = ItemCategories.Category_Name,     
"Last Sale Date" = (select Max(InvoiceAbstract.InvoiceDate)    
from InvoiceAbstract, InvoiceDetail    
where InvoiceAbstract.InvoiceDate < @FromDate and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceType in (1,2,3) and    
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
InvoiceDetail.Product_Code = Items.Product_Code),     
"Saleable Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Damaged Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Free Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Maximum Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) 
When N'Conversion Factor' Then ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Total Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) 
When N'Conversion Factor' Then ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0)
When N'Reporting UOM' Then ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else ISNULL(Items.ReportingUnit, 0) End)
Else (ISNULL((select Sum(Quantity) from Batch_products     
where Batch_Products.Product_Code = Items.Product_Code), 0)  
/ (Case @UOM --When 'Sales UOM' Then 1  
When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
End)) End,  
"Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products    
where Batch_Products.Product_Code = Items.Product_Code), 0)as Decimal(18,6))  
From Items, ItemCategories    
where     
Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )    
from InvoiceDetail, InvoiceAbstract    
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceType in (1,2,3)) and    
Items.CategoryID = ItemCategories.CategoryID    
AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)    
end  

