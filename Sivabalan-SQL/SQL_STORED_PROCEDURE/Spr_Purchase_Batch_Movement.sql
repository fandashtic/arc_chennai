CREATE Procedure Spr_Purchase_Batch_Movement (@Manufacturer nvarchar(255), 
                                              @Hierarchy nvarchar(255),  
                                              @Category nvarchar(255), 
                                              @ProductCode nvarchar(255), 
                                              @ProductName nvarchar(255),   
                                              @BatchNumber nvarchar(255), 
                                              @FromDate DateTime, 
                                              @ToDate DateTime)  
As  
  
Create Table #tempCategory(CategoryID Int, Status Int)  
Exec GetLeafCategories @Hierarchy, @Category  
Select Distinct CategoryID InTo #temcat From #tempCategory  
  
Select i.Product_Code, "Item Code" = i.Product_Code, 
	"Item Name" = i.ProductName,   
	"Tot Qty" = IsNull([Purchase], 0) - IsNull([Purchase Return], 0),  
	"UOM1" = Case When IsNull(i.UOM1, 0) < 1 or IsNull(i.UOM1_Conversion, 0) < 1 Then ' ' Else  
					   Cast(((IsNull([Purchase], 0) - IsNull([Purchase Return], 0)) / i.UOM1_Conversion) As nvarchar) + ' ' + (Select   
					   UOM.[Description] From Items, UOM Where UOM1 = UOM.UOM And Product_Code = i.Product_code) End,  
	"UOM2" = Case When IsNull(i.UOM2, 0) < 1 or IsNull(i.UOM2_Conversion, 0) < 1 Then ' ' Else   
					   Cast(((IsNull([Purchase], 0) - IsNull([Purchase Return], 0)) / i.UOM2_Conversion) As nvarchar) + ' ' + (Select   
					   UOM.[Description] From Items, UOM Where UOM2 = UOM.UOM And Product_Code = i.Product_code)End,  
	"Reporting Unit" = Case When IsNull(i.ReportingUOM, 0) < 1 or  
					   IsNull(i.ReportingUnit, 0) < 1  Then ' ' Else   
					   Cast( ((IsNull([Purchase], 0) - IsNull([Purchase Return], 0)) / i.ReportingUnit) As nvarchar) + ' ' + (Select   
					   UOM.[Description] From Items, UOM Where ReportingUOM = UOM.UOM And Product_Code = i.Product_code) End,   
	"Conversion Factor" = Case When IsNull(i.ConversionFactor, 0) < 1 or  
					   IsNull(i.ConversionUnit, 0) < 1 Then ' ' Else   
					   Cast(((IsNull([Purchase], 0) - IsNull([Purchase Return], 0)) * i.ConversionFactor) As nvarchar) + ' ' + (Select   
					   ConversionTable.ConversionUnit From Items, ConversionTable Where Items.ConversionUnit = ConversionID And   
                       Product_Code = i.Product_Code) End,   
	"Count Of GRN" = (Select Count(GRNAbstract.GRNID) From GRNAbstract, GRNDetail Where   
					  GRNAbstract.GRNID = GRNDetail.GRNID And Product_Code = i.Product_Code And GRNDate Between   
				      @FromDate And @ToDate) From ( 
					  Select "Item Code" = i.Product_Code, 
					  "Purchase" = (Select   
				      Sum(IsNull(QuantityReceived, 0) + IsNull(FreeQty ,0)) From GRNAbstract, GRNDetail Where GRNAbstract.GRNID = GRNDetail.GRNID   
					  And GRNDate Between @FromDate And @ToDate And Product_code = i.Product_Code And  
				      IsNull(GRNStatus, 0) & 96 = 0),  
					  "Purchase Return" = (Select Sum(IsNull(Quantity, 0)) From AdjustmentReturnAbstract, AdjustmentReturnDetail  
				      Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID And   
					  AdjustmentDate Between @FromDate And @ToDate And Product_code = i.Product_Code And   
					  IsNull(Status, 0) & 192 = 0)  
					  From Items i, Batch_Products bp Where i.Product_Code = bp.Product_Code And  
					  i.Product_Code Like @ProductCode And ProductName Like @ProductName And   
					  bp.Batch_Number Like @BatchNumber Group By i.Product_Code)   
	qty, Items i, Manufacturer ma, #temcat  
    Where qty.[Item Code] = i.Product_Code And   
	i.ManufacturerID = ma.ManufacturerID And i.CategoryID = #temcat.CategoryID  
    And ma.Manufacturer_Name Like @Manufacturer  
  
Drop Table #tempCategory  
Drop Table #temcat  
  
  
  



