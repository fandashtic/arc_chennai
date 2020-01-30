CREATE Procedure Spr_Purchase_Batch_Movement_NoUOM
       (@Hierarchy nVarChar(255),     
        @Category nVarChar(2550),     
        @ProductCode nVarChar(2550),     
        @Manufacturer nVarChar(2550),  
        @BatchNumber nVarChar(255),     
        @FromDate DateTime,     
        @ToDate DateTime)      
As      

Create Table #tempCategory(CategoryID Int, Status Int)      
Exec GetLeafCategories @Hierarchy, @Category      
Select Distinct CategoryID InTo #temcat1 From #tempCategory
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
    
Create table #tmpMan(Man nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create table #tmpPro(Pro nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
    
If @Manufacturer = N'%'       
   Insert into #tmpMan select Manufacturer_Name from Manufacturer      
Else      
   Insert into #tmpMan select * from dbo.sp_SplitIn2Rows(@Manufacturer, @Delimeter)      
    
    
If @ProductCode = N'%'       
   Insert into #tmpPro select Product_Code from Items      
Else      
   Insert into #tmpPro select * from dbo.sp_SplitIn2Rows(@ProductCode, @Delimeter)      

Select i.Product_Code,     
  "Item Code" = i.Product_Code,     
  "Item Name" = i.ProductName,       
  "Tot Qty" = IsNull([Purchase], 0) - IsNull([Purchase Return], 0),      
  "Reporting Unit" = dbo.sp_Get_ReportingQty ((IsNull([Purchase], 0) - IsNull([Purchase Return], 0)), i.ReportingUnit),    
  "UOM Description" = (Select UOM.[Description] From Items, UOM Where     
    ReportingUOM = UOM.UOM And Product_Code = i.Product_code),      
  "Conversion Factor" = (IsNull([Purchase], 0) - IsNull([Purchase Return], 0)) *     
    Case When IsNull(i.ConversionFactor, 0) < 1  Then 1 Else       
    i.ConversionFactor End,    
--     "UOM Description" = IsNull((Select       
--     IsNull(ConversionTable.ConversionUnit, '') From Items, ConversionTable Where     
--     Items.ConversionUnit = ConversionID And       
--     Product_Code = i.Product_Code), ''),      
  "Count Of GRN" = (Select Count(GRNAbstract.GRNID) From GRNAbstract, GRNDetail Where       
    GRNAbstract.GRNID = GRNDetail.GRNID And Product_Code = i.Product_Code And GRNDate Between       
    @FromDate And @ToDate And IsNull(GRNStatus, 0) & 96 = 0)     
From (Select "Item Code" = i.Product_Code,     
      "Purchase" = (Select Sum(IsNull(QuantityReceived, 0) + IsNull(FreeQty ,0)) From GRNAbstract, GRNDetail     
        Where GRNAbstract.GRNID = GRNDetail.GRNID       
          And GRNDate Between @FromDate And @ToDate And Product_code = i.Product_Code And      
          IsNull(GRNStatus, 0) & 96 = 0),      
      "Purchase Return" = (Select Sum(IsNull(Quantity, 0))     
        From AdjustmentReturnAbstract, AdjustmentReturnDetail      
        Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID And    
          AdjustmentDate Between @FromDate And @ToDate And Product_code = i.Product_Code And    
          IsNull(AdjustmentReturnAbstract.Status, 0) & 192 = 0)      
      From Items i, Batch_Products bp Where i.Product_Code = bp.Product_Code And      
      i.Product_Code In (Select * From #tmpPro) And     
      bp.Batch_Number Like @BatchNumber     
      Group By i.Product_Code)       
qty, Items i, Manufacturer ma, #temcat1      
Where qty.[Item Code] = i.Product_Code And       
i.ManufacturerID = ma.ManufacturerID And i.CategoryID = #temcat1.CategoryID      
And ma.Manufacturer_Name In (Select * From #tmpMan)    
      
Drop Table #tempCategory      
Drop Table #tmpMan    
Drop Table #tmpPro      
Drop Table #temcat1






