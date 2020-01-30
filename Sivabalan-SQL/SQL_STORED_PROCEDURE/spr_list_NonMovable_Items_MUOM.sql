
Create procedure spr_list_NonMovable_Items_MUOM(@ShowItems nvarchar(255), @FromDate datetime, @ToDate datetime , @UOM nvarchar(50))    
as    
  
--This table is to display the categories in the Order  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Exec sp_CatLevelwise_ItemSorting   
  
If IsNull(@UOM,N'') = N'' or @UOM = N'%' or @UOM = N'Base UOM'   
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
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
 "Damaged Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,   
 "Free Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
   
 ----  
 "Saleable SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(IDR.saleprice, 0) > 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR , InvoiceAbstractReceived IAR      
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(IDR.Saleprice, 0) > 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR  
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
 ----  
 "Free SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(IDR.saleprice, 0) = 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR      
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(IDR.Saleprice, 0) = 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR 
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
  
  
 "Maximum Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
    where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
    where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
 "Total Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products     
   where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Quantity) from Batch_products     
   where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
   
 ----  
 "Total SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(IDR.pending) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(IDR.pending) from InvoiceDetailReceived IDR , InvoiceAbstractReceived IAR
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
 "Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products    
   where Batch_Products.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),  
 ----  
 "Total SIT Value" = Cast(ISNULL((Select Sum(IDR.pending * saleprice) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR       
   where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) as Decimal(18,6))  
 ----  
 From Items, ItemCategories, Batch_Products, #tempCategory1 T1  
 where     
 Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )    
  from InvoiceDetail, InvoiceAbstract    
  where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
  InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
  InvoiceAbstract.Status & 128 = 0 and    
  InvoiceAbstract.InvoiceType in (1,2,3)) And    
 Items.CategoryID = ItemCategories.CategoryID And   
 Batch_Products.Product_Code = Items.Product_Code And  
 Items.CategoryID = T1.CategoryID  
   group by T1.IDS, Items.Product_Code, Items.ProductName, Items.Description, ItemCategories.Category_Name,Items.UOM1_Conversion,Items.UOM2_Conversion  
   having sum(Batch_Products.Quantity) > 0  
   Order by T1.IDS  
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
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
 "Damaged Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Damage, 0) > 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
 "Free Stock" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) from Batch_products     
    where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
   
 ----  
 "Saleable SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(IDR.saleprice, 0) > 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR      
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(IDR.Saleprice, 0) > 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR         
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
 ----  
 "Free SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(Case When IsNull(IDR.saleprice, 0) = 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR        
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Case When IsNull(IDR.Saleprice, 0) = 0 Then IDR.pending Else 0 End) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR     
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
  
 "Maximum Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
    where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select MAX (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) from openingdetails   
    where openingdetails.product_code = Items.Product_Code and opening_date between @FromDate and @ToDate), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
 "Total Stock" = Case @UOM When N'Sales UOM' Then  ISNULL((select Sum(Quantity) from Batch_products     
   where Batch_Products.Product_Code = Items.Product_Code), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(Quantity) from Batch_products     
   where Batch_Products.Product_Code = Items.Product_Code), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,  
   
 ----  
 "Total SIT" = Case @UOM When N'Sales UOM' Then ISNULL((select Sum(IDR.pending) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) Else dbo.sp_Get_ReportingQty(ISNULL((select Sum(IDR.pending) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR 
    where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0)  
    , (Case @UOM --When 'Sales UOM' Then 1  
    When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)  
    When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)  
    End)) End,    
 ----  
 "Total Value" = Cast(ISNULL((Select Sum(Quantity * PurchasePrice) from Batch_Products    
   where Batch_Products.Product_Code = Items.Product_Code), 0)as Decimal(18,6)),  
 ----  
 "Total SIT Value" = Cast(ISNULL((Select Sum(pending * saleprice) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR      
   where IDR.Product_Code = Items.Product_Code And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0), 0) as Decimal(18,6))  
 ----  
 From Items, ItemCategories, #tempCategory1 T1    
 where     
 Items.Product_Code not in (select distinct(InvoiceDetail.Product_Code )    
 from InvoiceDetail, InvoiceAbstract    
 where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and    
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
 InvoiceAbstract.Status & 128 = 0 and    
 InvoiceAbstract.InvoiceType in (1,2,3)) and    
 Items.CategoryID = ItemCategories.CategoryID And  
    Items.CategoryID = T1.CategoryID   
    Order by T1.IDS  
    end  

