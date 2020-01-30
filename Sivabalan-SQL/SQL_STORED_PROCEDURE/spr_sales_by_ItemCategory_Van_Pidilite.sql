CREATE procedure [dbo].[spr_sales_by_ItemCategory_Van_Pidilite](        
@CATNAME NVARCHAR (4000),                  
@Beat nVarchar(2550),
@VAN nVARCHAR(100),          
@FROMDATE DATETIME,                  
@TODATE DATETIME                  
)        
As        
                  
DECLARE @UOMCOUNT int                  
DECLARE @REPORTINGCOUNT int                  
DECLARE @CONVERSIONCOUNT int                  
declare @UOMDESC nvarchar(50)                  
declare @ReportingUOM nvarchar(50)                  
declare @ConversionUnit nvarchar(50)                  

Declare @Delimeter as Char(1)                    
Set @Delimeter=Char(15)                    

Create table #tmpBeat(BeatID Int)      

if @Beat = N'%'      
   Insert into #tmpBeat select BeatID from Beat      
Else      
   Insert into #tmpBeat select BeatID From Beat Where Description In (Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter))

                  
Create Table #temp(CategoryID int,                  
     Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
     Status int)                  
                  
Create Table #TmpCat (Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                  
                  
If @CATNAME = N'%'                   
 Insert Into #TmpCat Select Category_Name From ItemCategories                  
Else                  
 Insert Into #TmpCat Select * From dbo.sp_SplitIn2Rows(@CATNAME,@Delimeter)                  
        
                 
Declare @Continue int                  
Declare @CategoryID int                  
Set @Continue = 1                  
Insert into #temp select CategoryID, Category_Name, 0 From ItemCategories                  
Where Category_Name in (Select Category From #TmpCat)                  
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
--Select * From #temp                  
--Select CategoryID, category_Name From ItemCategories Where CategoryID not in                  
--(Select CategoryID From #temp)                  
                  
Select @UOMCOUNT = Count(Distinct Items.UOM)                  
From Items, InvoiceDetail, ItemCategories, InvoiceAbstract,Van                  
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND           
InvoiceAbstract.VanNumber=Van.Van And          
InvoiceAbstract.VanNumber=@VAN And                 
InvoiceDetail.Product_Code = Items.Product_Code AND                  
Items.CategoryID = ItemCategories.CategoryID AND                  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND                  
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND                  
InvoiceAbstract.Status & 128 = 0 AND                  
InvoiceAbstract.InvoiceType in (1, 2, 3)                  
                  
Select @REPORTINGCOUNT = Count(Distinct Items.ReportingUOM)                   
From Items, ItemCategories, InvoiceAbstract, InvoiceDetail,Van                  
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                  
InvoiceAbstract.VanNumber=Van.Van And          
InvoiceAbstract.VanNumber=@VAN And                 
InvoiceDetail.Product_Code = Items.Product_Code AND                  
Items.CategoryID = ItemCategories.CategoryID AND                  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND               
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND              
InvoiceAbstract.Status & 128 = 0 AND                  
InvoiceAbstract.InvoiceType in (1, 2, 3)              
            
                  
Select @CONVERSIONCOUNT = Count(Distinct Items.ConversionUnit)                  
From Items, ItemCategories, InvoiceAbstract, InvoiceDetail,Van            
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                  
InvoiceAbstract.VanNumber=Van.Van And          
InvoiceAbstract.VanNumber=@VAN And                 
InvoiceDetail.Product_Code = Items.Product_Code AND                  
Items.CategoryID = ItemCategories.CategoryID AND                  
ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND                  
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND                  
InvoiceAbstract.Status & 128 = 0 AND                  
InvoiceAbstract.InvoiceType in (1, 2, 3)                  
                  
If @UOMCOUNT <= 1 And @REPORTINGCOUNT <= 1 And @CONVERSIONCOUNT <= 1                  
Begin                  
 Select Top 1 @UOMDESC = UOM.Description                   
 From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, UOM,Van                  
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                  
 InvoiceAbstract.VanNumber=Van.Van And          
 InvoiceAbstract.VanNumber=@VAN And                 
 InvoiceDetail.Product_Code = Items.Product_Code AND                  
 Items.CategoryID = ItemCategories.CategoryID AND                  
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND                  
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND                  
 InvoiceAbstract.Status & 128 = 0 AND                  
 InvoiceAbstract.InvoiceType in (1, 2, 3) AND                  
 Items.UOM *= UOM.UOM                  
            
 Select Top 1 @ReportingUOM  = UOM.Description             
 From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, UOM,Van            
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND            
 InvoiceAbstract.VanNumber=Van.Van And          
 InvoiceAbstract.VanNumber=@VAN And                 
 InvoiceDetail.Product_Code = Items.Product_Code AND            
 Items.CategoryID = ItemCategories.CategoryID AND            
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND            
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND            
 InvoiceAbstract.Status & 128 = 0 AND            
 InvoiceAbstract.InvoiceType in (1, 2, 3) AND            
 Items.ReportingUOM *= UOM.UOM            
            
                   
 Select Top 1 @ConversionUnit = ConversionTable.ConversionUnit                  
 From Items, InvoiceDetail, ItemCategories, InvoiceAbstract, ConversionTable,Van                  
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND          
 InvoiceAbstract.VanNumber=Van.Van And          
 InvoiceAbstract.VanNumber=@VAN And                 
 InvoiceDetail.Product_Code = Items.Product_Code AND                  
 Items.CategoryID = ItemCategories.CategoryID AND                  
 ItemCategories.Category_Name  In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp) AND                  
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND                  
 InvoiceAbstract.Status & 128 = 0 AND                  
 InvoiceAbstract.InvoiceType in (1, 2, 3) AND                  
 Items.ConversionUnit *= ConversionTable.ConversionID                  
                  
 Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name,"Van"=Van.Van,                   
 "Net Quantity" = ISNULL(SUM(Quantity), 0),                  
 "Conversion Factor" = CAST(CAST(SUM(ISNULL(Quantity, 0) * Items.ConversionFactor) AS Decimal(18,6)) AS nVARCHAR)                  
 + ' ' + @ConversionUnit,                  
--  "Reporting UOM" = Cast(dbo.Sp_Get_ReportingQty(Sum(ISNULL(QUANTITY, 0)), (CASE Cast(IsNull(Items.ReportingUnit,0) as Int) WHEN 0 THEN 1 ELSE Cast(IsNull(Items.ReportingUnit,1) as Int) END)) As nVarChar)            
--   + ' ' + @ReportingUOM,                  
                  
--  SubString(                  
--  CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS VARCHAR), 1,                   
--  CharIndex('.', CAST(CAST(SUM(ISNULL(QUANTITY, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,6)) AS VARCHAR)) -1)                  
--  + '.' +                   
--  CAST(Sum(Cast(ISNULL(QUANTITY, 0) As Int)) % Avg(Cast((CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) As Int)) AS VARCHAR)                  
--  + ' ' + @ReportingUOM,                  
 "Reporting UOM" = CAST(CAST(SUM(ISNULL(Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END)) AS Decimal(18,2)) AS nVarchar)  
 + N' ' + @ReportingUOM,                  
 "Net Value (%c)" = sum(Amount)                   
 from invoicedetail,InvoiceAbstract,ItemCategories, Items,Van                  
 where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID               
 and InvoiceAbstract.VanNumber=Van.Van          
 and InvoiceAbstract.VanNumber=@VAN          
 and invoicedate between @FROMDATE and @TODATE                  
 And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)                  
 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)                  
 And InvoiceAbstract.BeatID In (Select BeatID From #tmpBeat)
 and items.CategoryID=Itemcategories.CategoryID                   
 and items.product_Code=invoiceDetail.product_Code                  
 Group by Items.CategoryID,ItemCategories.Category_Name,Van.Van, Items.ReportingUnit            
End                  
Else                  
Begin                  
 Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name,"Van"=Van.Van,                            
 "Net Quantity" = ISNULL(SUM(Quantity), 0),                  
 "Conversion Factor" = Null,                  
 "Reporting UOM" = Null,                  
 "Net Value (%c)" = sum(Amount)                   
 from invoicedetail,InvoiceAbstract,ItemCategories, Items,Van                  
 where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID                   
 and InvoiceAbstract.VanNumber=Van.Van          
 and InvoiceAbstract.VanNumber=@VAN          
 and invoicedate between @FROMDATE and @TODATE                  
 And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)                  
 And ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #temp)                  
 And InvoiceAbstract.BeatID In (Select BeatID From #tmpBeat)
 and items.CategoryID=Itemcategories.CategoryID                   
 and items.product_Code=invoiceDetail.product_Code                  
 Group by Items.CategoryID,ItemCategories.Category_Name,Van.Van                  
End                  
Drop Table #temp                  
Drop Table #TmpCat                 

SET QUOTED_IDENTIFIER OFF
