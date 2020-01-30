CREATE procedure [dbo].[spr_lists_Purchase_by_ItemCategory]    
                (@CATNAME nvarchar (255),    
   		 @VENDORNAME nvarchar(255),       
                 @FROMDATE DATETIME,    
                 @TODATE DATETIME)    
As    
DECLARE @UOMCOUNT int    
DECLARE @REPORTINGCOUNT int    
DECLARE @CONVERSIONCOUNT int    
declare @UOMDESC nvarchar(50)    
declare @ReportingUOM nvarchar(50)    
declare @ConversionUnit nvarchar(50)  

-- Added for handling multiple category

Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpCat(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
	  
if @CatName='%'       
     Insert into #tmpCat select Category_Name from ItemCategories      
Else      
     Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@CatName,@Delimeter)      

-- multiple category ends  
    
Create Table #temp(CategoryID int, Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  Status int)    
Declare @Continue int    
Declare @CategoryID int    
Set @Continue = 1    
  
Insert into #temp   
Select CategoryID, Category_Name, 0   
From ItemCategories    
Where Category_Name in (Select #tmpCat.Category COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCat) -- multiple category
  
While @Continue > 0    
Begin    
  Declare Parent Cursor Static For    
  Select CategoryID From #temp Where Status = 0    
  Open Parent    
  Fetch From Parent Into @CategoryID    
  While @@Fetch_Status = 0    
   Begin    
    Insert into #temp     
    Select CategoryID, Category_Name, 0 From ItemCategories     
    Where ParentID = @CategoryID    
    Update #temp Set Status = 1 Where CategoryID = @CategoryID    
    Fetch Next From Parent Into @CategoryID    
   End    
Close Parent    
DeAllocate Parent    
Select @Continue = Count(*) From #temp Where Status = 0    
End    
    
Select @UOMCOUNT = Count(Distinct Items.UOM)  
From Items, BillDetail, ItemCategories, BillAbstract  
WHERE BillAbstract.BillID = BillDetail.BillID AND  
BillDetail.Product_Code = Items.Product_Code AND  
Items.CategoryID = ItemCategories.CategoryID AND  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
BillAbstract.Status & 128 = 0 

  
Select @REPORTINGCOUNT = Count(Distinct Items.ReportingUnit)   
From Items, ItemCategories, BillAbstract, BillDetail  
WHERE BillAbstract.BillID = BillDetail.BillID AND  
BillDetail.Product_Code = Items.Product_Code AND  
Items.CategoryID = ItemCategories.CategoryID AND  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
BillAbstract.Status & 128 = 0  
  
Select @CONVERSIONCOUNT = Count(Distinct Items.ConversionUnit)  
From Items, ItemCategories, BillAbstract, BillDetail  
WHERE BillAbstract.BillID = BillDetail.BillID AND  
BillDetail.Product_Code = Items.Product_Code AND  
Items.CategoryID = ItemCategories.CategoryID AND  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
BillAbstract.Status & 128 = 0 

-- select @UOMCOUNT , @REPORTINGCOUNT, @CONVERSIONCOUNT
-- select * from #temp

If @UOMCOUNT <= 1 And @REPORTINGCOUNT <= 1 And @CONVERSIONCOUNT <= 1  
Begin  
 Select Top 1 @UOMDESC = UOM.Description   
 From Items
 Inner Join BillDetail On BillDetail.Product_Code = Items.Product_Code 
 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
 Inner Join BillAbstract On BillAbstract.BillID = BillDetail.BillID 
 Left Outer Join UOM On Items.UOM = UOM.UOM  
 WHERE 
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
 BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
 BillAbstract.Status & 128 = 0 
    
 Select Top 1 @ReportingUOM  = UOM.Description   
 From Items
 Inner Join BillDetail On BillDetail.Product_Code = Items.Product_Code 
 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID 
 Inner Join BillAbstract On BillAbstract.BillID = BillDetail.BillID
 Left Outer Join UOM On Items.ReportingUOM = UOM.UOM     
 WHERE 
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
 BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
 BillAbstract.Status & 128 = 0 

 Select Top 1 @ConversionUnit = ConversionTable.ConversionUnit  
 From Items
 Inner Join BillDetail On BillDetail.Product_Code = Items.Product_Code 
 Left Outer Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
 Inner Join BillAbstract On BillAbstract.BillID = BillDetail.BillID 
 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID  
 WHERE 
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND  
 BillAbstract.BillDate Between @FROMDATE And @TODATE AND  
 BillAbstract.Status & 128 = 0 
 
 Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name,     
 "Parent Category" = p.Category_Name ,
 "Net Quantity" = ISNULL(SUM(Quantity), 0),    
 "Conversion Factor" = CAST(CAST(SUM(ISNULL(Quantity, 0) * Items.ConversionFactor) AS DECIMAL(18, 2)) AS nvarchar)  
 + ' ' + @ConversionUnit,    
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(Sum(ISNULL(QUANTITY, 0)), Items.ReportingUnit) As nvarchar) 
--   SubString(
--    CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar), 1, 
--    CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS nvarchar)) -1)
--   + '.' + 
--   CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS nvarchar)
--   + ' ' + @ReportingUOM,
--  "Reporting UOM" = CAST(CAST(SUM(ISNULL(Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS DECIMAL(18, 2)) AS nvarchar)  
  + ' ' + @ReportingUOM,
 "Net Value (%c)" = sum(Amount + BillDetail.TaxAmount)     
 from Billdetail
 Inner Join BillAbstract On BillAbstract.BillID=BillDetail.BillID     
 Inner Join Items On items.product_Code=BillDetail.product_Code    
 Inner Join ItemCategories On items.CategoryID=Itemcategories.CategoryID     
 Inner Join Vendors On BillAbstract.VendorID = Vendors.VendorID  
 Left Outer Join ItemCategories p On p.CategoryID = Itemcategories.ParentID
 where Billdate between @FROMDATE and @TODATE    
 And BillAbstract.Status&128=0   
 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)    
 and Vendors.Vendor_Name like @VENDORNAME  
 Group by Items.CategoryID,ItemCategories.Category_Name, p.Category_Name, Items.ReportingUnit

End  
Else  
Begin  
 Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name,   
 "Parent Category" = p.Category_Name ,
 "Net Quantity" = ISNULL(SUM(Quantity), 0),  
 "Conversion Factor" = Null,  
 "Reporting UOM" = Null,  
 "Net Value (%c)" = sum(Amount + BillDetail.TaxAmount)    
 from Billdetail
 Inner Join BillAbstract On BillAbstract.BillID=BillDetail.BillID     
 Inner Join Items On  items.product_Code=BillDetail.product_Code    
 Inner Join ItemCategories On items.CategoryID=Itemcategories.CategoryID     
 Inner Join Vendors On BillAbstract.VendorID = Vendors.VendorID  
 Left Outer Join ItemCategories p On p.CategoryID = Itemcategories.ParentID
 where Billdate between @FROMDATE and @TODATE    
 And BillAbstract.Status&128=0   
 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)    
 and Vendors.Vendor_Name like @VENDORNAME  
 Group by Items.CategoryID,ItemCategories.Category_Name, p.Category_Name

End 
Drop Table #temp    
Drop Table #tmpCat  -- temp table created for handling multiple category
