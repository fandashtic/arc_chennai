CREATE PROCEDURE spr_TradeLoadDetails(@Hierarchy nvarchar(50), @Category nvarchar(100) , @FROMDATE datetime, @TODATE datetime)      
AS        
    
DECLARE @BRAND_NAME nvarchar(50)        
DECLARE @DynamicSQL nvarchar(256)        
DECLARE @DynamicOutlet nvarchar(4000)        
    
-- to find the level of the passed hierarchy      
Declare @level int        
if @Category like '%'       
begin      
 select @Level = HierarchyId from ItemHierarchy where HierarchyName like @Hierarchy       
end      
else      
begin      
 select @Level = HierarchyId from ItemHierarchy where HierarchyName like @Category      
end      
    
-- to get the cat rec in a #table       
Create Table #Cattemp (CategoryID int, Category_Name nvarchar(255),Status int)          
Declare @Continue int          
Declare @CategoryID int          
Set @Continue = 1          
    
-- insert the first category in this level      
Insert into #Cattemp  select CategoryID,Category_Name,0 From ItemCategories      
 where Category_Name in (select category_name from Itemcategories       
        where [level] = @Level and Category_name like @Category)      
While @Continue > 0          
Begin      
 Declare Parent Cursor Static For          
 Select CategoryID From #Cattemp Where Status = 0          
 Open Parent          
 Fetch From Parent Into @CategoryID          
 While @@Fetch_Status = 0          
 Begin          
  Insert into #Cattemp  Select CategoryID, Category_Name, 0 From ItemCategories       
  Where ParentID = @CategoryID          
  Update #Cattemp  Set Status = 1 Where CategoryID = @CategoryID          
  Fetch Next From Parent Into @CategoryID          
 End          
 Close Parent          
 DeAllocate Parent          
 Select @Continue = Count(*) From #Cattemp Where Status = 0          
End       
-- all the cate have been dumped      
    
-- now the actual proc      
Create Table #temp(InvoiceDate DateTime,InvoiceID int, BrandName nvarchar(255),CategoryName nvarchar(255),ProductCode nvarchar(255))        
Create Table #PivotTable(InvoiceDate DateTime,InvoiceID int primary key clustered)       
Insert into #temp        
Select  "InvoiceDate" = InvoiceAbstract.InvoiceDate  
, "InvoiceID" = InvoiceAbstract.InvoiceID     
, "BrandName" = dbo.getDivisionName(InvoiceDetail.Product_Code)  
, "CategoryName" = ItemCategories.Category_Name
--, "CategoryName" = dbo.getBrandName(InvoiceDetail.Product_Code, @Level)        
, "ProductCode" = InvoiceDetail.Product_Code    
From  InvoiceAbstract, InvoiceDetail , Items , ItemCategories    
Where  (InvoiceAbstract.Status & 128) = 0       
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID     
And InvoiceDetail.Product_Code = Items.Product_Code     
And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE        
And Items.Categoryid = ItemCategories.Categoryid       
And ItemCategories.Categoryid in (select Categoryid from #CatTemp)      
Group By InvoiceAbstract.InvoiceDate, InvoiceAbstract.InvoiceID , InvoiceDetail.Product_Code,ItemCategories.Category_Name
Order By InvoiceAbstract.InvoiceDate    
    
--select 'Ram',* from #Temp    
-- now since all details is in the #temp table, filter it        
Declare @SaleBRAND_NAME nvarchar(255)    
Declare @FreeBRAND_NAME nvarchar(255)    
DECLARE AddBrandAsColumns CURSOR STATIC FOR  -- dec a cursor to handle item wise      
Select Distinct BrandName From #temp        
        
Open AddBrandAsColumns        
FETCH FROM AddBrandAsColumns Into @BRAND_NAME        
While @@FETCH_STATUS = 0  -- generating cols in the name of each item      
BEGIN        
 SET @SaleBRAND_NAME = @BRAND_NAME + ' - SaleQty'    
 SET @DynamicSQL = 'ALTER TABLE #PivotTable Add [' + @SaleBRAND_NAME + '] nvarchar(255) Null'         
 exec sp_executesql @DynamicSQL        
 SET @FreeBRAND_NAME = @BRAND_NAME + ' - FreeQty'    
 SET @DynamicSQL = 'ALTER TABLE #PivotTable Add [' + @FreeBRAND_NAME + '] nvarchar(255) Null'   
 exec sp_executesql @DynamicSQL        
 FETCH NEXT FROM AddBrandAsColumns Into @BRAND_NAME        
END        
Close AddBrandAsColumns        
DeAllocate AddBrandAsColumns        
    
Insert Into #PivotTable(InvoiceID, InvoiceDate) Select InvoiceID, dbo.stripdatefromtime(InvoiceDate) From #temp Group By InvoiceID , InvoiceDate    
  
--Update Sale and Free Qty     
Declare @UpdateBrand nvarchar(255)    
Declare @ProductCode nvarchar(255)    
Declare @InvoiceID int    
Declare @SaleQty int    
Declare @FreeQty int    
Declare UpdateSalesValue CURSOR STATIC FOR        

select (InvoiceID) , (BrandName) , (CategoryName), ProductCode  from #Temp --Group By ProductCode        
Open UpdateSalesValue        
FETCH FROM UpdateSalesValue Into @InvoiceID , @UpdateBrand , @Category , @ProductCode    
WHILE @@FETCH_STATUS = 0        
BEGIN        
 -- get the Sale and Free count      
  
 Select  @SaleQty = isnull(Sum(Quantity),0)    
 From  InvoiceAbstract , InvoiceDetail  ,Items , ItemCategories , Brand    
 Where (InvoiceAbstract.Status & 128) = 0       
 And InvoiceAbstract.InvoiceID = @InvoiceID    
 And InvoiceDetail.Product_Code = Items.Product_Code     
 And InvoiceDetail.Product_Code = @ProductCode    
 And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
 And InvoiceDetail.SalePrice > 0    
 And Items.Categoryid = ItemCategories.Categoryid       
 And ItemCategories.Category_Name Like @Category    
 And Items.BrandID = Brand.BrandID And Brand.BrandName Like @UpdateBrand    
 Select  @FreeQty = isnull(Sum(Quantity),0)    
 From  InvoiceAbstract , InvoiceDetail  ,Items , ItemCategories , Brand     
 Where (InvoiceAbstract.Status & 128) = 0       
 And InvoiceAbstract.InvoiceID = @InvoiceID    
 And InvoiceDetail.Product_Code = Items.Product_Code     
 And InvoiceDetail.Product_Code = @ProductCode    
 And IsNull(InvoiceDetail.FlagWord,0) = 1    
 And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
 And IsNull(InvoiceDetail.SalePrice,0) = 0    
 And Items.Categoryid = ItemCategories.Categoryid       
 And ItemCategories.Category_Name Like @Category    
 And Items.BrandID = Brand.BrandID   
 And Brand.BrandName Like @UpdateBrand    
  
 SET @SaleBRAND_NAME = @UpdateBrand + ' - SaleQty'    
  
 SET @DynamicSQL = 'Update #PivotTable Set [' + @SaleBRAND_NAME + '] = IsNull([' + @SaleBRAND_NAME + '],0) + '       
    + cast(@SaleQty as nvarchar) + ' Where InvoiceID = ' + cast(@InvoiceID as nvarchar)    
 exec sp_executesql @DynamicSQL        
    
 SET @FreeBRAND_NAME = @UpdateBrand + ' - FreeQty'    
  
 SET @DynamicSQL = 'Update #PivotTable Set [' + @FreeBRAND_NAME + '] = IsNull([' + @FreeBRAND_NAME + '],0) + '       
    + cast(@FreeQty as nvarchar) + ' Where InvoiceID = ' + cast(@InvoiceID as nvarchar)    
    
 exec sp_executesql @DynamicSQL        
 FETCH NEXT FROM UpdateSalesValue Into @InvoiceID , @UpdateBrand, @Category, @ProductCode    
END        
Close UpdateSalesValue        
DeAllocate UpdateSalesValue        
    
--Final Result    
Select InvoiceID,* From #PivotTable        
drop table #PivotTable        
drop table #temp      
drop table #Cattemp      
    


