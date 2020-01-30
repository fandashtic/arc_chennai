CREATE Procedure spr_Stock_Movement_CategoryGroupWise_Abstract_ITC (      
        @CategoryGroup nVarchar(2550),      
        @CategoryDiv nVarchar(2550),      
        @ItemCode nVarChar(2550),      
        @UOM nVarChar(255),  
  @AllItems nVarchar(255) ,     
        @StockValuationAt nVarChar(255),      
        @FromDate DateTime,      
        @ToDate DateTime)      
As      
      
Declare @Delimeter Char(1)         
Declare @Continue Int         
Declare @CategoryID Int         
Declare @Continue2 Int           
Declare @Inc Int         
Declare @TCat Int         
  
If @UOM = N'Base UOM'   
 Set @UOM = N'UOM'  
Else If @UOM = N'%'
 Set @UOM = N'UOM 2'

Set @Inc = 1         
Set @Continue = 1         
Set @Delimeter = Char(15)        
    
    
IF @StockValuationAt = N'%'     
 Set @StockValuationAt = N'Price to WD'    
    
     
     
Create Table #tmpCatGrp (GroupID Int, GroupName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
-- Create Table #tmpDiv(Division nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
Create Table #tmpProd (Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
Create Table #tmpCat(CategoryID Int, Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)         
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)            
Create Table #temp3 (CatID Int, Status Int)         
        
Create Table #temp4 (IDS Int IDENTITY(1, 1), LeafID Int, CatID Int,         
Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)         
      
Create Table #TempFinal (CatID Int,         
CatName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,         
OpeningQuantity Decimal(18, 6),         
FreeOpeningQuantity Decimal(18, 6), DamageOpeningQuantity Decimal(18, 6),         
TotalOpeningQuantity Decimal(18, 6), OpeningValue Decimal(18, 6),         
DamageOpeningValue Decimal(18, 6), TotalOpeningValue Decimal(18, 6),         
Purchase Decimal(18, 6), FreePurchase Decimal(18, 6), SalesReturnSaleable Decimal(18, 6),        
SalesReturnDamages Decimal(18, 6), TotalIssues Decimal(18, 6),         
SaleableIssues Decimal(18, 6), FreeIssues Decimal(18, 6), SalesValue Decimal(18, 6),        
PurchaseReturn Decimal(18, 6), Adjustments Decimal(18, 6), StockTransferOut Decimal(18, 6),        
StockTransferIn Decimal(18, 6), StockDestruction Decimal(18, 6), OnHandQty Decimal(18, 6),        
OnHandFreeQty Decimal(18, 6), OnHandDamageQty Decimal(18, 6),         
TotalOnHandQty Decimal(18, 6), OnHandValue Decimal(18, 6),         
OnHandDamagesValue Decimal(18, 6), TotalOnHandValue Decimal(18, 6))        
        
Create Table #Products(Product_Code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS Primary Key,        
ProductName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,        
UOM int,         
ReportingUOM int,         
ReportingUnit Decimal(18, 6),         
ConversionUnit Int,         
ConversionFactor Decimal(18, 6),        
UOM1 Int,        
UOM2 Int,        
UOM1_Conversion Decimal (18, 6),        
UOM2_Conversion Decimal (18, 6),        
CategoryID Int,         
Alias NVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,         
SalesReturnSaleable Decimal(18, 6) Default (0),         
SalesReturnDamages Decimal(18, 6) Default (0),         
SaleableIssues Decimal(18, 6) Default (0),         
FreeIssues Decimal(18, 6) Default (0),         
SalesValue Decimal(18, 6) Default (0))        
      
If @CategoryGroup = N'%'         
   Insert InTo #tmpCatGrp Select GroupID, GroupName From ProductCategoryGroupAbstract      
Else                  
   Insert InTo #tmpCatGrp  Select GroupID, GroupName From ProductCategoryGroupAbstract      
   Where GroupName In (Select * From dbo.sp_SplitIn2Rows(@CategoryGroup, @Delimeter))      
                  
-- If @Division = N'%'         
--    Insert InTo #tmpDiv Select BrandName From Brand         
-- Else   
--    Insert InTo #tmpDiv Select * From dbo.sp_SplitIn2Rows(@Division, @Delimeter)     
            
If @ItemCode = N'%'        
 Insert InTo #tmpProd Select Product_code From Items            
Else   
 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)            
        
-- Category Group Handling based on the CategoryGroup definition 

Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @TempCGCatMapping
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

If @CategoryDiv = N'%' And @CategoryGroup = N'%'            
Begin            
            
   Insert InTo #tmpCat Select Distinct ItemCategories.CategoryID, ItemCategories.Category_Name       
   From ItemCategories, @TempCGCatMapping As ProductCategoryGroupDetail       
   Where ProductCategoryGroupDetail.CategoryID = ItemCategories.CategoryID      
-- #tmpCat(CategoryID Int, Category             
End            
Else If @CategoryDiv = N'%' And @CategoryGroup != N'%'         
Begin            
            
 Insert InTo #tmpCat Select Distinct itc.CategoryID, itc.Category_Name       
 From ItemCategories itc, ProductCategoryGroupAbstract pcga, @TempCGCatMapping pcgd         
 Where pcga.GroupID = pcgd.GroupID And itc.CategoryID = pcgd.CategoryID       
 And pcga.GroupName In (Select * From dbo.sp_SplitIn2Rows(@CategoryGroup, @Delimeter))      
            
End            
Else                  
Begin            
            
   Insert InTo #tmpCat Select Distinct CategoryID, Category_Name       
   From ItemCategories Where ItemCategories.Category_Name In       
   (Select * From dbo.sp_SplitIn2Rows(@CategoryDiv, @Delimeter))      
          
End            
        
Insert InTo #temp2 Select CategoryID From ItemCategories              
Where ItemCategories.Category_Name In (Select Category From #tmpCat)              
      
Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)         
      
While @Inc <= @Continue2            
Begin        
  Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc         
  Select @TCat = CatID From #temp2 Where IDS = @Inc         
  While @Continue > 0        
  Begin                
    Declare Parent Cursor Keyset For                
    Select CatID From #temp3  Where Status = 0                
    Open Parent                
    Fetch From Parent Into @CategoryID                
    While @@Fetch_Status = 0                
    Begin                
      Insert into #temp3 Select CategoryID, 0 From ItemCategories         
      Where ParentID = @CategoryID        
      If @@RowCount > 0        
        Update #temp3 Set Status = 1 Where CatID = @CategoryID                
      Else                
        Update #temp3 Set Status = 2 Where CatID = @CategoryID                
        Fetch Next From Parent Into @CategoryID                
    End        
    Close Parent         
    DeAllocate Parent         
    Select @Continue = Count(*) From #temp3 Where Status = 0         
  End         
  Delete #temp3 Where Status not in  (0, 2)                
  Insert InTo #temp4 Select CatID, @TCat,         
  (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3         
  Delete #temp3            
  Set @Continue = 1            
  Set @Inc = @Inc + 1            
End            
      
Insert Into #Products (Product_Code, ProductName, UOM, ReportingUOM, ReportingUnit,       
ConversionUnit,        
ConversionFactor, UOM1, UOM2, UOM1_Conversion, UOM2_Conversion, CategoryID, Alias)         
Select Product_Code, ProductName, UOM, ReportingUOM, ReportingUnit, ConversionUnit,        
ConversionFactor, UOM1, UOM2, UOM1_Conversion, UOM2_Conversion, CategoryID, Alias        
From Items      
Where         
Items.CategoryID In (Select LeafID From #temp4) And         
Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)                
      
Create Table #Invoice(InvoiceID Int Primary Key, InvoiceType Int, Status Int)        
Insert Into #Invoice Select InvoiceID, InvoiceType, Status         
From InvoiceAbstract        
Where InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE         
AND (InvoiceAbstract.Status & 128) = 0                   
      
Select         
"Product_Code" = InvoiceDetail.Product_Code,         
"RSalesReturnSaleable" = Sum((Case         
When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) = 0) OR (#Invoice.InvoiceType = 5)) Then        
Quantity Else 0 End)),         
"RSalesReturnDamages" = Sum(Case         
When ((#Invoice.InvoiceType = 4 AND (#Invoice.Status & 32) <> 0) OR (#Invoice.InvoiceType = 6)) Then        
Quantity Else 0 End),        
"RSaleableIssues" = Sum(Case         
When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice > 0) Then        
Quantity Else 0 End),        
"RFreeIssues" = Sum(Case         
When (#Invoice.InvoiceType = 2 AND InvoiceDetail.SalePrice = 0) Then        
Quantity Else 0 End),        
"RSalesValue" = Sum(Case        
When (#Invoice.InvoiceType In (4, 5, 6)) Then 0 - Amount Else Amount End)        
Into #RetailInvoice         
From #Products, #Invoice, InvoiceDetail         
Where #Invoice.InvoiceID = InvoiceDetail.InvoiceID        
AND InvoiceDetail.Product_Code = #Products.Product_Code         
Group By InvoiceDetail.Product_Code        
      
Update #Products Set         
SalesReturnSaleable = SalesReturnSaleable + RSalesReturnSaleable,        
SalesReturnDamages = SalesReturnDamages + RSalesReturnDamages,        
SaleableIssues = SaleableIssues + RSaleableIssues,        
FreeIssues = FreeIssues + RFreeIssues,        
SalesValue = SalesValue + RSalesValue        
From #Products, #RetailInvoice        
Where #Products.Product_Code = #RetailInvoice.Product_Code        
      
Drop Table #RetailInvoice        
      
--Filter valid dispatches for the given dates        
Create Table #Dispatch(DispatchID Int Primary Key)        
        
Insert Into #Dispatch Select DispatchID From DispatchAbstract         
Where DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
AND (Isnull(DispatchAbstract.Status, 0) & 320) = 0        
      
Select         
"Product_Code" = #Products.Product_Code,        
"DSaleableIssues" = Sum(IsNull(Case When SalePrice > 0 Then        
Quantity Else 0 End, 0)),        
"DFreeIssues" = Sum(IsNull(Case When SalePrice = 0 OR FlagWord = 1 Then        
Quantity Else 0 End, 0))        
Into #DispatchDetail         
From #Products, #Dispatch, DispatchDetail        
Where #Dispatch.DispatchID = DispatchDetail.DispatchID        
AND DispatchDetail.Product_Code = #Products.Product_Code        
Group By #Products.Product_Code        
      
Update #Products Set        
SaleableIssues = SaleableIssues + DSaleableIssues,        
FreeIssues = FreeIssues + DFreeIssues        
From #Products, #DispatchDetail        
Where #Products.Product_Code = #DispatchDetail.Product_Code        
        
Drop Table #DispatchDetail        
      
Declare @NEXT_DATE DateTime         
DECLARE @CORRECTED_DATE DateTime         
        
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS NVarchar) + N'/'                   
+ CAST(DATEPART(mm, @TODATE) as NVarchar) + N'/'                   
+ cast(DATEPART(yyyy, @TODATE) AS NVarchar)                  
        
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS NVarchar) + N'/'                   
+ CAST(DATEPART(mm, GETDATE()) as NVarchar) + N'/'                   
+ cast(DATEPART(yyyy, GETDATE()) AS NVarchar)                  
      
----------------------------------------------------      
      
Insert InTo #TempFinal         
SELECT  --"CatID" = #temp4.CatID, "CatName" = #temp4.Parent,         
      
"CatID" = #tmpCatGrp.GroupID , "CatName" = #tmpCatGrp.GroupName,      
"OpeningQuantity" =           
Cast(Case @UOM         
When 'UOM' Then         
 (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))          
-- When 'Reporting UOM' Then         
--  dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
-- When 'Conversion Factor' Then         
--  (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) *           
--  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
When 'UOM 1' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
When 'UOM 2' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
End as Decimal(18, 6)),        
        
"FreeOpeningQuantity" =           
Cast(Case @UOM         
When 'UOM' Then         
 (ISNULL(Free_Saleable_Quantity, 0))          
-- When 'Reporting UOM' Then           
--  dbo.sp_Get_ReportingQty((ISNULL(Free_Saleable_Quantity, 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
-- When 'Conversion Factor' Then (ISNULL(Free_Saleable_Quantity, 0)) *          
--  (Case IsNull(#Products.ConversionFactor, 0)         
--  When 0 Then 1 Else #Products.ConversionFactor End)          
When 'UOM 1' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Free_Saleable_Quantity, 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
When 'UOM 2' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Free_Saleable_Quantity, 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
End as Decimal(18, 6)),        
        
"DamageOpeningQuantity" =           
Cast(Case @UOM         
When 'UOM' Then         
 (ISNULL(Damage_Opening_Quantity, 0))          
-- When 'Reporting UOM' Then           
--  dbo.sp_Get_ReportingQty((ISNULL(Damage_Opening_Quantity, 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
-- When 'Conversion Factor' Then         
--  (ISNULL(Damage_Opening_Quantity, 0)) *           
--  (Case IsNull(#Products.ConversionFactor, 0)         
--  When 0 Then 1 Else #Products.ConversionFactor End)          
When 'UOM 1' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Damage_Opening_Quantity, 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
When 'UOM 2' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Damage_Opening_Quantity, 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
End as Decimal(18, 6)),        
        
"TotalOpeningQuantity" =           
Cast(Case @UOM         
When 'UOM' Then         
 (ISNULL(Opening_Quantity, 0))          
-- When 'Reporting UOM' Then           
--  dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
-- When 'Conversion Factor' Then         
--  (ISNULL(Opening_Quantity, 0)) *           
--  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
When 'UOM 1' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
When 'UOM 2' Then         
 dbo.sp_Get_ReportingQty((ISNULL(Opening_Quantity, 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
End as Decimal(18, 6)),        
        
"OpeningValue" = -- ISNULL(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),                  
Case @StockValuationAt       
When N'Price to WD' Then      
(ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) * Items.PTS      
When N'Sales Price' Then      
(ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) * Items.PTR      
End,      
                  
"DamageOpeningValue" = --IsNull(Damage_Opening_Value, 0),           
Case @StockValuationAt      
When N'Price to WD' Then      
(ISNULL(Damage_Opening_Quantity, 0)) * Items.PTS      
When N'Sales Price' Then      
(ISNULL(Damage_Opening_Quantity, 0)) * Items.PTR      
End,      
      
          
"TotalOpeningValue" = --ISNULL(Opening_Value, 0),        
Case @StockValuationAt      
When N'Price to WD' Then      
(ISNULL(Opening_Quantity, 0) - IsNull(Free_Opening_Quantity, 0)) * Items.PTS      
When N'Sales Price' Then      
(ISNULL(Opening_Quantity, 0) - IsNull(Free_Opening_Quantity, 0)) * Items.PTR      
End,       
      
"Purchase" =           
 Cast(Case @UOM         
 When 'UOM' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                   
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0))          
--  When 'Reporting UOM' Then            
--   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)          
--   FROM GRNAbstract, GRNDetail                   
--   WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
--   AND GRNDetail.Product_Code = #Products.Product_Code                   
--   AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
--   (GRNAbstract.GRNStatus & 64) = 0 And                  
--   (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                   
--   FROM GRNAbstract, GRNDetail                   
--   WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
--   AND GRNDetail.Product_Code = #Products.Product_Code                   
--   AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
--   (GRNAbstract.GRNStatus & 64) = 0 And                  
--   (GRNAbstract.GRNStatus & 32) = 0 ), 0)) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"FreePurchase" =           
 Cast(Case @UOM         
 When 'UOM' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))                   
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0))          
--     When 'Reporting UOM' Then    
--   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(IsNull(FreeQty, 0))          
--   FROM GRNAbstract, GRNDetail                   
--   WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
--   AND GRNDetail.Product_Code = #Products.Product_Code                   
--   AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
--   (GRNAbstract.GRNStatus & 64) = 0 And                  
--   (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))                   
--   FROM GRNAbstract, GRNDetail                   
--   WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
--   AND GRNDetail.Product_Code = #Products.Product_Code                   
--   AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
--   (GRNAbstract.GRNStatus & 64) = 0 And                  
--   (GRNAbstract.GRNStatus & 32) = 0 ), 0)) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(IsNull(FreeQty, 0))          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(IsNull(FreeQty, 0))          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID                   
  AND GRNDetail.Product_Code = #Products.Product_Code                   
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And                   
  (GRNAbstract.GRNStatus & 64) = 0 And                  
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"SalesReturnSaleable" =        
 Cast(Case @UOM         
 When 'UOM' Then         
  SalesReturnSaleable        
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty(SalesReturnSaleable, Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--  When 'Conversion Factor' Then         
--   SalesReturnSaleable *        
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty(SalesReturnSaleable, Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty(SalesReturnSaleable, Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"SalesReturnDamages" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  SalesReturnDamages        
--  When 'Reporting UOM' Then          
--   dbo.sp_Get_ReportingQty(SalesReturnDamages, Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--  When 'Conversion Factor' Then         
--   SalesReturnDamages *        
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)        
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty(SalesReturnDamages, Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty(SalesReturnDamages, Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"TotalIssues" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  SaleableIssues + FreeIssues        
--  When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty(SaleableIssues + FreeIssues, Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--  When 'Conversion Factor' Then         
--   (SaleableIssues + FreeIssues) *        
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty(SaleableIssues + FreeIssues, Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty(SaleableIssues + FreeIssues, Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),          
        
"SaleableIssues" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  SaleableIssues        
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty(SaleableIssues, Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--  When 'Conversion Factor' Then         
--   SaleableIssues *         
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty(SaleableIssues, Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty(SaleableIssues, Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),          
        
"FreeIssues" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  FreeIssues        
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty(FreeIssues, Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--  When 'Conversion Factor' Then         
--   FreeIssues *        
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty(FreeIssues, Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty(FreeIssues, Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"SalesValue" = SalesValue,        
        
"PurchaseReturn" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  (ISNULL((SELECT SUM(Quantity)                   
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code                   
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE               
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0              
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0))          
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity)          
--   FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
--   WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
--   AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code                   
--   AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE               
--   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0              
--   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then         
--   (ISNULL((SELECT SUM(Quantity)                   
--   FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
--   WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
--   AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code                   
--   AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE               
--   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0              
--   And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)        
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity)          
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code                   
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE               
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0              
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity)          
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code                   
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE               
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0              
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"Adjustments" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  (ISNULL((SELECT SUM(Quantity - OldQty)                   
  FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3)                   
  And Product_Code = #Products.Product_Code                   
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))   
--  When 'Reporting UOM' Then            
--   dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity - OldQty)          
--   FROM StockAdjustment, StockAdjustmentAbstract                   
--   WHERE ISNULL(AdjustmentType,0) in (1, 3)                   
--   And Product_Code = #Products.Product_Code                   
--   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
--   AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then         
--   (ISNULL((SELECT SUM(Quantity - OldQty)                   
--   FROM StockAdjustment, StockAdjustmentAbstract                   
--   WHERE ISNULL(AdjustmentType,0) in (1, 3)                   
--   And Product_Code = #Products.Product_Code                   
--   AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
--   AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity - OldQty)          
  FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3)             
  And Product_Code = #Products.Product_Code                   
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((ISNULL((SELECT  SUM(Quantity - OldQty)          
  FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3)                   
  And Product_Code = #Products.Product_Code                   
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID           
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"StockTransferOut" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  (IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferOutAbstract.Status & 192 = 0                  
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0))          
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty((IsNull((Select Sum(Quantity)                   
--   From StockTransferOutAbstract, StockTransferOutDetail                  
--   Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
--   And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                   
--   And StockTransferOutAbstract.Status & 192 = 0                  
--   And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then         
--   (IsNull((Select Sum(Quantity)                   
--   From StockTransferOutAbstract, StockTransferOutDetail                  
--   Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
--   And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                   
--   And StockTransferOutAbstract.Status & 192 = 0                  
--   And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)) *        
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferOutAbstract.Status & 192 = 0                  
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferOutAbstract.Status & 192 = 0                  
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),          
        
"StockTransferIn" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  (IsNull((Select Sum(Quantity)                   
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferInAbstract.Status & 192 = 0                  
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0))           
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty((IsNull((Select  Sum(Quantity)          
--   From StockTransferInAbstract, StockTransferInDetail                   
--   Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
--   And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                   
--   And StockTransferInAbstract.Status & 192 = 0                  
--   And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then         
--   (IsNull((Select Sum(Quantity)                   
--   From StockTransferInAbstract, StockTransferInDetail                   
--   Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
--   And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                   
--   And StockTransferInAbstract.Status & 192 = 0                 
--   And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)                                  
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((IsNull((Select  Sum(Quantity)          
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferInAbstract.Status & 192 = 0                  
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)),  Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
dbo.sp_Get_ReportingQty((IsNull((Select  Sum(Quantity)          
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                   
  And StockTransferInAbstract.Status & 192 = 0                  
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
 End as Decimal(18, 6)),        
        
"StockDestruction" =           
 Cast(Case @UOM         
 When 'UOM' Then         
  (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                           
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote               
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                          
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID              
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                           
  And ClaimsNote.Status & 1 <> 0                  
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6)))          
--  When 'Reporting UOM' Then           
--   dbo.sp_Get_ReportingQty((cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)          
--   From StockDestructionAbstract, StockDestructionDetail,ClaimsNote               
--   Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                          
--   And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID              
--   And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                           
--   And ClaimsNote.Status & 1 <> 0                  
--   And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--  When 'Conversion Factor' Then         
--   (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                           
--   From StockDestructionAbstract, StockDestructionDetail,ClaimsNote               
--   Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID              
--   And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                           
--   And ClaimsNote.Status & 1 <> 0                  
--   And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))) *           
--   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
 When 'UOM 1' Then         
  dbo.sp_Get_ReportingQty((cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)          
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote               
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                          
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID              
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                           
  And ClaimsNote.Status & 1 <> 0                  
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
 When 'UOM 2' Then         
  dbo.sp_Get_ReportingQty((cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)          
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote               
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                          
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID              
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                           
  And ClaimsNote.Status & 1 <> 0                  
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
      
 End as Decimal(18, 6)),          
        
        
"OnHandQty" =         
 Cast(        
 CASE when (@TODATE < @NEXT_DATE) THEN                   
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
   WHERE OpeningDetails.Product_Code = #Products.Product_Code           
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
   WHERE OpeningDetails.Product_Code = #Products.Product_Code           
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
   WHERE OpeningDetails.Product_Code = #Products.Product_Code           
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 ELSE                   
  Case @UOM         
  When 'UOM' Then         
   ((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
   IsNull(Damage, 0) = 0), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
And VanStatementDetail.Product_Code = #Products.Product_Code And           
   VanStatementDetail.PurchasePrice <> 0)))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then             
--    ((ISNULL((SELECT  SUM(Quantity)          
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
   IsNull(Damage, 0) = 0), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And           
   VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
   IsNull(Damage, 0) = 0), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And           
   VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 End as Decimal(18, 6)),                  
        
"OnHandFreeQty" =           
 Cast(        
 CASE when (@TODATE < @NEXT_DATE) THEN              
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Free_Saleable_Quantity, 0)                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 ELSE                 
  Case @UOM         
  When 'UOM' Then         
   ((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)               
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial       
   AND (VanStatementAbstract.Status & 128) = 0           
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0)))         
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +            
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    ((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +            
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then  
   dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 End as Decimal(18, 6)),                  
        
"OnHandDamageQty" =         
 Cast(CASE When (@TODATE < @NEXT_DATE) THEN                   
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
   FROM OpeningDetails           
   WHERE OpeningDetails.Product_Code = #Products.Product_Code            
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then             
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)         
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
   FROM OpeningDetails           
   WHERE OpeningDetails.Product_Code = #Products.Product_Code            
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
   FROM OpeningDetails           
   WHERE OpeningDetails.Product_Code = #Products.Product_Code            
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 ELSE                   
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((SELECT SUM(Quantity)           
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
-- FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End )          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 End as Decimal(18, 6)),                  
        
"TotalOnHandQty" =         
 Cast(CASE         
 When (@TODATE < @NEXT_DATE) THEN                   
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((Select Opening_Quantity                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then            
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity                  
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 ELSE                   
  Case @UOM         
  When 'UOM' Then         
   (ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
  When 'UOM 1' Then         
   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
  When 'UOM 2' Then         
   dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
  End          
 End as Decimal(18, 6)),                  
        
"OnHandValue" =         
--  CASE         
--  when (@TODATE < @NEXT_DATE) THEN                   
--   ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)                  
--   FROM OpeningDetails                   
--   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
--  ELSE                   
--   ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                   
--   FROM Batch_Products                   
--   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +                   
--   (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                   
--   FROM VanStatementDetail, VanStatementAbstract                   
--   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--   AND (VanStatementAbstract.Status & 128) = 0                   
--   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.SalePrice <> 0))                  
--  end,                  
Case @StockValuationAt      
when N'Price to WD' Then      
 Cast(        
 CASE when (@TODATE < @NEXT_DATE) THEN                   
--   Case @UOM         
--   When 'UOM' Then         
   (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
   WHERE OpeningDetails.Product_Code = #Products.Product_Code           
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
  ELSE                   
--   Case @UOM         
--   When 'UOM' Then         
   ((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And     
   IsNull(Damage, 0) = 0), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And           
   VanStatementDetail.PurchasePrice <> 0)))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then             
--    ((ISNULL((SELECT  SUM(Quantity)          
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
-- else      
--  When 'UOM 1' Then         
--   dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
        
--  End          
 End as Decimal(18, 6)) * Items.PTS      
When N'Sales Price' Then      
 Cast(      
 CASE when (@TODATE < @NEXT_DATE) THEN                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
   WHERE OpeningDetails.Product_Code = #Products.Product_Code           
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)        
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)          
--    - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails          
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code           
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 ELSE                   
--  Case @UOM         
--  When 'UOM' Then         
   ((ISNULL((SELECT SUM(Quantity)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
   IsNull(Damage, 0) = 0), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code And           
   VanStatementDetail.PurchasePrice <> 0)))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then             
--    ((ISNULL((SELECT  SUM(Quantity)          
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)               --    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty(((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And           
--    IsNull(Damage, 0) = 0), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code And           
--    VanStatementDetail.PurchasePrice <> 0))), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 End as Decimal(18, 6)) * Items.PTR          
End,      
        
"OnHandDamagesValue" =         
--  CASE                   
--  when (@TODATE < @NEXT_DATE) THEN                   
--   ISNULL((Select IsNull(Damage_Opening_Value, 0)                  
--   FROM OpeningDetails                   
--   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
--  ELSE                   
--   (SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                   
--   FROM Batch_Products                   
--   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0)                  
--  end,                   
Case @StockValuationAt      
When 'Price to WD' Then       
 Cast(CASE When (@TODATE < @NEXT_DATE) THEN                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((Select (IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - isNull(free_saleable_quantity, 0)))      
   FROM OpeningDetails           
   WHERE OpeningDetails.Product_Code = #Products.Product_Code            
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then             
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code         
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 ELSE                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((SELECT SUM(Quantity)           
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) > 0), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End )          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 End as Decimal(18, 6)) * Items.PTS      
When N'Sales Price' Then      
 Cast(CASE When (@TODATE < @NEXT_DATE) THEN                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((Select (IsNull(Damage_Opening_Quantity, 0) - (IsNull(Free_Opening_Quantity, 0) - isNull(free_saleable_quantity, 0)))      
   FROM OpeningDetails           
   WHERE OpeningDetails.Product_Code = #Products.Product_Code            
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then             
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select IsNull(Damage_Opening_Quantity, 0)                  
--    FROM OpeningDetails           
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code            
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 ELSE                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((SELECT SUM(Quantity)           
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) > 0), 0))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End )          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)           
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 End as Decimal(18, 6)) * Items.PTR      
End ,      
      
      
        
"TotalOnHandValue" =         
--  CASE                   
--  when (@TODATE < @NEXT_DATE) THEN                   
--   ISNULL((Select Opening_Value                  
--   FROM OpeningDetails                   
--   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                  
--  ELSE                   
--   ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                   
--   FROM Batch_Products                   
--   WHERE Product_Code = #Products.Product_Code) +                   
--   (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                   
--   FROM VanStatementDetail, VanStatementAbstract                   
--   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--   AND (VanStatementAbstract.Status & 128) = 0                   
--   And VanStatementDetail.Product_Code = #Products.Product_Code))                  
--  end        
      
Case @StockValuationAt      
When N'Price to WD' Then      
 Cast(CASE         
 When (@TODATE < @NEXT_DATE) THEN                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((Select (Opening_Quantity - isnull(Free_Opening_Quantity,0))      
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then            
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity            
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select (Opening_Quantity - Free_Opening_Quantity)      
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select (Opening_Quantity - Free_Opening_Quantity)      
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End         
 ELSE                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0  Then 0 Else  Quantity End)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
   AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0  Then 0 Else  Quantity End)                   
--    FROM Batch_Products           
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0  Then 0 Else  Quantity End)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 End as Decimal(18, 6)) * Items.PTS      
When N'Sales Price' Then       
 Cast(CASE         
 When (@TODATE < @NEXT_DATE) THEN                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((Select (Opening_Quantity - isnull(Free_Opening_Quantity,0))      
   FROM OpeningDetails                   
   WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))          
--   When 'Reporting UOM' Then            
--    dbo.sp_Get_ReportingQty((ISNULL((Select Opening_Quantity                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code               
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)           
--   When 'Conversion Factor' Then         
--    (ISNULL((Select Opening_Quantity                  
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select (Opening_Quantity - Free_Opening_Quantity)      
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((Select (Opening_Quantity - Free_Opening_Quantity)      
--    FROM OpeningDetails                   
--    WHERE OpeningDetails.Product_Code = #Products.Product_Code                   
--    AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 ELSE                   
--  Case @UOM         
--  When 'UOM' Then         
   (ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0 Then 0 Else Quantity End)                   
   FROM Batch_Products                   
   WHERE Product_Code = #Products.Product_Code), 0) +                  
   (SELECT ISNULL(SUM(Pending), 0)                   
   FROM VanStatementDetail, VanStatementAbstract                   
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                  
AND (VanStatementAbstract.Status & 128) = 0                   
   And VanStatementDetail.Product_Code = #Products.Product_Code))          
--   When 'Reporting UOM' Then           
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Quantity)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.ReportingUnit, 1) When 0 Then 1 Else IsNull(#Products.ReportingUnit, 1) End)          
--   When 'Conversion Factor' Then         
--    (ISNULL((SELECT SUM(Quantity)                
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)) *           
--    (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)          
--   When 'UOM 1' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0 Then 0 Else Quantity End)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM1_Conversion, 1) End)          
--   When 'UOM 2' Then         
--    dbo.sp_Get_ReportingQty((ISNULL((SELECT SUM(Case When IsNull(Purchaseprice, 0) = 0 Then 0 Else Quantity End)                   
--    FROM Batch_Products                   
--    WHERE Product_Code = #Products.Product_Code), 0) +                  
--    (SELECT ISNULL(SUM(Pending), 0)                   
--    FROM VanStatementDetail, VanStatementAbstract                   
--    WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
--    AND (VanStatementAbstract.Status & 128) = 0                   
--    And VanStatementDetail.Product_Code = #Products.Product_Code)), Case IsNull(#Products.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(#Products.UOM2_Conversion, 1) End)          
--         
--   End          
 End as Decimal(18, 6)) * Items.PTR      
End       
      
FROM #Products
Left Outer Join OpeningDetails On #Products.Product_Code = OpeningDetails.Product_Code
Left Outer Join  UOM On  #Products.UOM = UOM.UOM 
Inner Join  ItemCategories On #Products.CategoryID = ItemCategories.CategoryID
Inner Join #temp4 On #Products.CategoryID = #temp4.LeafID 
Inner Join @TempCGCatMapping As ProductCategoryGroupDetail On #temp4.CatID = ProductCategoryGroupDetail.CategoryID
Inner Join #tmpCatGrp On ProductCategoryGroupDetail.GroupID = #tmpCatGrp.GroupID 
Inner Join Items On #Products.Product_Code = Items.Product_Code            
WHERE OpeningDetails.Opening_Date = @FROMDATE                
      
----------------------------------------------------------------------      
      
-- If IsNull((Select Count(Distinct UOM.[Description])       
-- FROM #Products, OpeningDetails, UOM, ItemCategories, #temp4        
-- WHERE #Products.Product_Code *= OpeningDetails.Product_Code AND                -- OpeningDetails.Opening_Date = @FROMDATE                
-- AND #Products.UOM *= UOM.UOM And                
-- #Products.CategoryID = ItemCategories.CategoryID And         
-- #Products.CategoryID = #temp4.LeafID), 0)  = 1        
-- Begin        
 Select --CatName,       
 CatId, "Category Group Name" = CatName,       
-- "GroupID" = #tmpCatGrp.GroupID , "CategoryGroupName" = #tmpCatGrp.GroupName,      
 "Opening Quantity" = Sum(OpeningQuantity),         
 "Free Opening Quantity" = Sum(FreeOpeningQuantity),         
 "Damage Opening Quantity" = Sum(DamageOpeningQuantity),         
 "Total Opening Quantity" = Sum(TotalOpeningQuantity),         
 "Opening Value" = Sum(OpeningValue),         
 "Damage Opening Value" = Sum(DamageOpeningValue),         
 "Total Opening Value" = Sum(TotalOpeningValue),         
 "Purchase" = Sum(Purchase), "Free Purchase" = Sum(FreePurchase),         
 "Sales Return Saleable" = Sum(SalesReturnSaleable),        
 "Sales Return Damages" = Sum(SalesReturnDamages),         
 "TotalIssues" = Sum(TotalIssues),         
 "Saleable Issues" = Sum(SaleableIssues),         
 "Free Issues" = Sum(FreeIssues),         
 "Sales Value" = Sum(SalesValue),        
 "Purchase Return" = Sum(PurchaseReturn), "Adjustments" = Sum(Adjustments),         
 "Stock Transfer Out" = Sum(StockTransferOut),        
 "Stock Transfer In" = Sum(StockTransferIn), "Stock Destruction" = Sum(StockDestruction),         
 "On Hand Qty" = Sum(OnHandQty),        
 "On Hand Free Qty" = Sum(OnHandFreeQty),         
 "On Hand Damage Qty" = Sum(OnHandDamageQty),         
 "Total On Hand Qty" = Sum(TotalOnHandQty), "On Hand Value" = Sum(OnHandValue),         
 "On Hand Damages Value" = Sum(OnHandDamagesValue),         
 "Total On Hand Value" = Sum(TotalOnHandValue) From #TempFinal Group By         
 CatID, CatName        
-- End        
-- Else        
-- Begin        
--  Select CatName, "Category Group Name" = CatName, "Opening Quantity" = 0,         
--  "Free Opening Quantity" = 0,         
--  "Damage Opening Quantity" = 0,         
--  "Total Opening Quantity" = 0,         
--  "Opening Value" = 0,         
--  "Damage Opening Value" = 0,         
--  "Total Opening Value" = 0,         
--  "Purchase" = 0, "Free Purchase" = 0,         
--  "Sales Return Saleable" = 0,        
--  "Sales Return Damages" = 0,         
--  "TotalIssues" = 0,         
--  "Saleable Issues" = 0,         
--  "Free Issues" = 0,         
--  "Sales Value" = 0,        
--  "Purchase Return" = 0, "Adjustments" = 0,         
--  "Stock Transfer Out" = 0,        
--  "Stock Transfer In" = 0, "Stock Destruction" = 0,         
--  "On Hand Qty" = 0,        
--  "On Hand Free Qty" = 0,         
--  "On Hand Damage Qty" = 0,         
--  "Total On Hand Qty" = 0, "On Hand Value" = 0,         
--  "On Hand Damages Value" = 0,         
--  "Total On Hand Value" = 0 From #TempFinal Group By         
--  CatID, CatName        
--         
-- End        
      
-- Drop Table #tmpMfr        
-- Drop Table #tmpDiv        
Drop Table #tmpCatGrp      
Drop Table #tmpProd         
Drop Table #tmpCat        
Drop Table #temp2        
Drop Table #temp3        
Drop Table #temp4         
--Drop Table #temp5         
Drop Table #Products        
Drop Table #TempFinal        
      


