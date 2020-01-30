CREATE procedure [dbo].[spr_list_Sales_By_Coverage_Type_Townwise]       
(         
@Product_Hierarchy nvarchar(256),         
@Category nvarchar(2550),         
@UOM nvarchar(256),         
@FromDate DateTime,         
@ToDate DateTime        
 )        
AS        
DECLARE @AlterSQL nvarchar(4000)                      
DECLARE @UpdateSQL nvarchar(4000)         
Declare @SQLStr nvarchar(4000)         
Declare @ProdName nvarchar(255)        
Declare @ProdCode nvarchar(255)        
Declare @TempProd nvarchar(255)    
Declare @SalesQty Decimal(18,6)  
Declare @City nvarchar(255)        
Declare @Qty Decimal(18,6)       
Declare @ItemUOM nvarchar(255)        
Declare @TownClassify nvarchar(255)    
Declare @OTHERS As NVarchar(50)      
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
        
Create Table #tempCategory(CategoryID int,   --Table Used for Product hierachy Filter        
      Status int)        
        
Exec dbo.GetLeafCategories @Product_Hierarchy, @Category  -- Stores CategoryID to Temp Table #tempCategory        
        
-- Town details and its corresponding outlet stored in a temp table        
Create Table #TownSales (TempTown nvarchar(255), Town nvarchar(255), [Town Classification] nvarchar(255), Outlets Integer)         
Insert into #TownSales (TempTown, Town, [Town Classification],  Outlets)        
   
(Select Distinct Isnull(City.CityName, N'zzzzz'), Isnull(City.CityName,@OTHERS),         
Case(Customer.TownClassify)        
When 1 Then        
N'Base Town'        
When 2 Then        
N'Satellite'        
When 3 Then        
N'Rural Rural'        
When 4 Then        
N'Rural Urban'        
Else        
N''        
End,         
Count(D.CustomerID) from Customer, City,     
(Select DispatchAbstract.CustomerID, DispatchAbstract.DispatchID from     
DispatchAbstract, Items, DispatchDetail where     
DispatchAbstract.DispatchID = DispatchDetail.DispatchID    
and DispatchDate between @FromDate and @ToDate     
and DispatchDetail.Product_Code = Items.Product_Code    
and Isnull(Status & 64,0) = 0        
and Items.CategoryID In (Select CategoryID From #tempCategory)         
Group by DispatchAbstract.CustomerID, DispatchAbstract.DispatchID) D    
Where Customer.CityID *= City.CityID          
and D.CustomerID = Customer.CustomerID         
Group By City.CityName, Customer.TownClassify)        
          
-- Citywise Sales stored temp in Cursor        
If @UOM = N'Sales UOM' or @UOM = N'Reporting UOM'        
Declare TownSales Cursor For        
Select ProdCode, ItemCode, City, TownClassify, Sum(Qty), UOM from  
(Select Distinct Items.ProductName  "ProdCode", "ItemCode" = Items.Product_Code, "City" = Isnull(City.CityName, @OTHERS),         
"TownClassify" = Case(Customer.TownClassify)        
When 1 Then        
N'Base Town'        
When 2 Then        
N'Satellite'        
When 3 Then        
N'Rural Rural'        
When 4 Then        
N'Rural Urban'        
Else        
N''        
End,         
"Qty" = (-1) * Sum(InvoiceDetail.Quantity),"UOM" = isnull(UOM.Description, N'')       
From InvoiceDetail, InvoiceAbstract, City, Customer, Items, UOM, Batch_Products    
Where Customer.CityID *= City.CityID        
and InvoiceDetail.Product_Code = Items.Product_Code        
and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code  
and InvoiceAbstract.CustomerID = Customer.CustomerID        
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
and InvoiceDate between @FromDate and @ToDate        
and Isnull(Status & 192,0) = 0      
and InvoiceType in (4)         
and Isnull(Batch_Products.Damage, 0) = 0   
and Items.CategoryID In (Select CategoryID From #tempCategory)         
and Items.UOM = UOM.UOM      
Group By Items.ProductName, Items.Product_Code, City.CityName, InvoiceType, Customer.TownClassify, UOM.Description       
Union      
Select Distinct Items.ProductName, Items.Product_Code, Isnull(City.CityName, @OTHERS),         
Case(Customer.TownClassify)        
When 1 Then        
N'Base Town'        
When 2 Then        
N'Satellite'        
When 3 Then        
N'Rural Rural'        
When 4 Then        
N'Rural Urban'        
Else        
N''        
End,         
Sum(DispatchDetail.Quantity), isnull(UOM.Description, N'')     
From DispatchDetail, DispatchAbstract, City, Customer, Items, UOM        
Where Customer.CityID *= City.CityID        
and DispatchDetail.Product_Code = Items.Product_Code        
and DispatchAbstract.CustomerID = Customer.CustomerID        
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID        
and DispatchDate between @FromDate and @ToDate        
and Isnull(Status & 64,0) = 0       
and Items.CategoryID In (Select CategoryID From #tempCategory)       
and Items.UOM = UOM.UOM      
Group By Items.ProductName, Items.Product_Code, City.CityName, Customer.TownClassify, UOM.Description          
) I  
Group by  ProdCode, ItemCode, City, TownClassify, UOM   
     
    
Else If @UOM = N'Conversion Factor'        
Declare TownSales Cursor For        
Select ProdCode, ItemCode, City, TownClassify, Sum(Qty), UOM from  
(Select Distinct Items.ProductName  "ProdCode", "ItemCode" = Items.Product_Code, "City" = Isnull(City.CityName, @OTHERS),         
"TownClassify" = Case(Customer.TownClassify)        
When 1 Then        
N'Base Town'        
When 2 Then        
N'Satellite'        
When 3 Then        
N'Rural Rural'        
When 4 Then        
N'Rural Urban'        
Else        
N''        
End,      
"Qty" = (-1) * Sum(InvoiceDetail.Quantity) * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END), "UOM" = Isnull(ConversionTable.ConversionUnit, N'')           
From InvoiceDetail, InvoiceAbstract, City, Customer, Items, ConversionTable, Batch_products     
Where Customer.CityID *= City.CityID        
and InvoiceDetail.Product_Code = Items.Product_Code        
and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code  
and InvoiceAbstract.CustomerID = Customer.CustomerID        
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
and InvoiceDate between @FromDate and @ToDate        
and Isnull(Status & 192,0) = 0      
and InvoiceType in (4)         
and Isnull(Damage, 0) = 0  
and Items.CategoryID In (Select CategoryID From #tempCategory)         
and Items.ConversionUnit *= ConversionTable.ConversionID      
Group By Items.ProductName, Items.Product_Code, City.CityName, InvoiceType, Customer.TownClassify, ConversionTable.ConversionUnit, Items.ConversionFactor            
Union      
Select Distinct Items.ProductName, Items.Product_Code, Isnull(City.CityName, @OTHERS),         
Case(Customer.TownClassify)        
When 1 Then        
N'Base Town'        
When 2 Then        
N'Satellite'        
When 3 Then        
N'Rural Rural'        
When 4 Then        
N'Rural Urban'        
Else        
N''        
End,         
Sum(DispatchDetail.Quantity) * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END), Isnull(ConversionTable.ConversionUnit, N'')       
From DispatchDetail, DispatchAbstract, City, Customer, Items, ConversionTable       
Where Customer.CityID = City.CityID        
and DispatchDetail.Product_Code = Items.Product_Code        
and DispatchAbstract.CustomerID = Customer.CustomerID        
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID        
and DispatchDate between @FromDate and @ToDate        
and Isnull(Status & 64,0) = 0       
and Items.CategoryID In (Select CategoryID From #tempCategory)       
and Items.ConversionUnit *= ConversionTable.ConversionID      
Group By Items.ProductName, Items.Product_Code, City.CityName, ConversionTable.ConversionUnit, Customer.TownClassify, Items.ConversionFactor          
) I  
Group by  ProdCode, ItemCode, City, TownClassify, UOM    
        
Set @TempProd = N''        
OPEN TownSales        
FETCH FROM TownSales Into @ProdName, @ProdCode, @City, @TownClassify, @Qty, @ItemUOM       
WHILE @@FETCH_STATUS = 0                      
BEGIN             
 If (Isnull(@TempProd,N'') <> Isnull(@ProdCode, N'')) OR (isnull(@TempProd, N'') = N'')        
 Begin        
 -- Checked whether square bracket appears in Item Name        
 If CHARINDEX('[',@ProdCode,1) <> 0 or  CHARINDEX(']',@ProdCode,1) <> 0         
 Begin        
 Set @ProdCode = Replace(@ProdCode, '[',' ')      
 Set @ProdCode = Replace(@ProdCode, ']',' ')        
 End         
        
  -- Product name added as field in Temp Table        
  SET @AlterSQL = N'ALTER TABLE #TownSales Add [' + @ProdCode +  '] nvarchar(255) null'                 
          
  EXEC sp_executesql @AlterSQL          
  Set @TempProd = isnull(@ProdCode, '')        
 End         
If @UOM = N'Reporting UOM'        
Begin      
 Set @Qty = dbo.sp_Get_ReportingUOMQty(@ProdCode, @Qty)        
  -- Quantity updated for Temp table        
 SET @UpdateSQL = N'Update #TownSales Set [' + @ProdCode + '] = N''' + cast(@Qty as nvarchar) +  ''' Where Town collate SQL_Latin1_General_Cp1_CI_AS = N'''+ @City + ''' and [Town Classification] collate SQL_Latin1_General_Cp1_CI_AS = N''' + @TownClassify + ''''       
 exec sp_executesql @UpdateSQL         
End      
Else      
Begin       
 Set @SalesQty = Cast(@Qty as Decimal(18,6))    
  -- Quantity updated for Temp table        
 SET @UpdateSQL = N'Update #TownSales Set [' + @ProdCode + '] = N''' + cast(@SalesQty as nvarchar)  +  ''' Where Town collate SQL_Latin1_General_Cp1_CI_AS = N'''+ @City + ''' and [Town Classification] collate SQL_Latin1_General_Cp1_CI_AS = N''' + @TownClassify
  + ''''         
 exec sp_executesql @UpdateSQL         
End      
      
FETCH NEXT FROM TownSales Into @ProdName, @ProdCode, @City, @TownClassify, @Qty, @ItemUOM        
END        
       
select * from #TownSales        
Close TownSales        
Deallocate TownSales        
Drop Table #TownSales        
Drop Table #tempCategory
