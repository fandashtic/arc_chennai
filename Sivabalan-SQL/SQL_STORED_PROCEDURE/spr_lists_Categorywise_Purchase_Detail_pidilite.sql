CREATE Procedure spr_lists_Categorywise_Purchase_Detail_pidilite
                                                      (@BillID Int,
                                                       @CATNAME NVARCHAR (2550),
                                                       @FROMDATE DATETIME,
                                                       @TODATE DATETIME)
As      

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories N'%', @CATNAME
Select Distinct CategoryID InTo #temp1 From #tempCategory

Select bd.Product_Code, 
  "Item Code" = bd.Product_Code,
  "Item Name" = i.ProductName,
  "Batch" = bd.Batch,
  "PKD" = bd.PKD,
  "Expiry" = bd.Expiry,
  "Manufacturer Name" = m.Manufacturer_Name,
  "Quantity" = Sum(bd.Quantity),
  "Reporting UOM" = Sum(bd.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),  
  "UOM Description" = IsNull((Select [Description] From UOM Where UOM = i.ReportingUOM), N''),
  "Conversion Factor" = Sum(bd.Quantity * IsNull(ConversionFactor, 0)),  
  "Purchase Price" = bd.PurchasePrice,
  "Amount" = Sum(bd.Quantity * bd.PurchasePrice)
From BillAbstract ba, BillDetail bd, Items i, Manufacturer m, #temp1 
Where ba.BillID = bd.BillID And bd.Product_Code = i.Product_Code And 
  m.ManufacturerID = i.ManufacturerID And i.CategoryID = #temp1.CategoryID And
  ba.BillDate Between @FromDate And @ToDate And IsNull(ba.Status, 0) & 192 = 0 And
  ba.BillID = @BillID

Group By bd.Product_Code, i.ProductName, bd.Batch, bd.PKD, bd.Expiry, m.Manufacturer_Name,
  i.ReportingUnit, i.ReportingUOM, bd.PurchasePrice


Drop Table #tempCategory
Drop Table #temp1




