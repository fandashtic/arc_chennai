CREATE procedure [dbo].[spr_list_stockmovement_report_34new](@HierarchyName varchar(255),
						    @UOM nvarchar(50),
						    @FROMDATE datetime,
				                    @TODATE datetime)
as              
  
declare @Level int  
set @level = (Select HierarchyId from Itemhierarchy where HierarchyName = @HierarchyName)  
  
create table #Temp1(CatID int, LevelID int)  
  
Exec Spr_GetLevel @Level  
  
CREATE table #Temp2(Product_Code nvarchar(30),Item_Code nvarchar(30),Item_Name nvarchar(510),UOM nvarchar(510),  
Opening_Quantity decimal(20),Free_Opening_Quantity decimal(20),Damage_Opening_Quantity decimal(20),  
Purchase decimal(20),Sales_Return decimal(20),Issues decimal(20),  
Ready_Stock_Sales decimal(20),Order_Booking decimal(20),Direct_Sales decimal(20),  
Free_Issues decimal(20),Purchase_Return decimal(20),Adjustments decimal(20),  
Stock_Transfer_Out decimal(20),Stock_Transfer_In decimal(20),On_Hand_Quantity decimal(20),  
On_Hand_Free_Quantity decimal(20),On_Hand_Damage_Quantity decimal(20),LevelID Decimal(18,2))  
  
declare @NEXT_DATE datetime              
DECLARE @CORRECTED_DATE datetime              
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/' + CAST(DATEPART(mm, @TODATE) as varchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS varchar)              
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)              
  
  
if @UOM = 'Sales UOM'              
  
begin              
Insert into #Temp2    
 SELECT  Items.Product_Code,  
 "Item Code" = Items.Product_Code,   
 "Item Name" = ProductName,               
  
 "Sales UOM" = UOM.Description,    
 "Opening Quantity" = ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0),   
 "Free Opening Quantity" = ISNULL(Free_Saleable_Quantity, 0),  
 "Damage Opening Quantity" = ISNULL(Damage_Opening_Quantity, 0),  
 "Purchase" = ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty,0) )   
 FROM GRNAbstract, GRNDetail               
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND   
 GRNDetail.Product_Code = Items.Product_Code AND   
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0), 0),  
               
 "Sales Return" = ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 4)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),  
               
 "Issues" = (ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 And InvoiceDetail.SalePrice <> 0), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0)),  
  
 "Ready Stock Sales" = (IsNull((Select Sum(Quantity)  
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 16 <> 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code And  
 (IsNull(InvoiceAbstract.Status, 0) & 128) = 0), 0)),  
      
 "Order Booking" = (IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 7 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)  
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 128) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0)),  
  
 "Direct Sales" = (IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)   
 + IsNull((Select Sum(Quantity) From InvoiceAbstract, InvoiceDetail  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceType = 2 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 InvoiceDetail.SalePrice <> 0 And  
 InvoiceDetail.Product_Code = Items.Product_Code), 0)),  
  
 "Free Issues" = (ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE   
 And InvoiceDetail.SalePrice = 0), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice = 0), 0)),  
             
 "Purchase Return" = ISNULL((SELECT SUM(Quantity)   
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract   
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code       
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(AdjustmentReturnAbstract.Status,0) & 64) = 0), 0),  
                
 "Adjustments" = ISNULL((SELECT SUM(Quantity - OldQty)   
 FROM StockAdjustment, StockAdjustmentAbstract  
 WHERE ISNULL(AdjustmentType,0) = 1  AND  
 Product_Code = Items.Product_Code AND   
 StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID             
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0),  
  
 "Stock Transfer Out" = (IsNull((select sum(quantity)   
 from stocktransferoutdetail,stocktransferoutabstract  
 where stocktransferoutabstract.docserial = stocktransferoutdetail.docserial  
 and stocktransferoutabstract.documentdate between @fromdate and @todate  
 and StockTransferOutDetail.Product_Code = Items.Product_Code), 0)),  
  
 "Stock Transfer In" = (IsNull((select sum(quantity)   
 from stocktransferindetail,stocktransferinabstract  
 where stocktransferinabstract.docserial = stocktransferindetail.docserial  
 and stocktransferinabstract.documentdate between @fromdate and @todate  
 and StockTransferinDetail.Product_Code = Items.Product_Code), 0)),  
              
 "On Hand Qty" = CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +  
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end,  
   
 "On Hand Free Qty" = CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +  
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end,  
  
 "On Hand Damage Qty" = CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end,  
   
 #Temp1.LevelID  
 FROM Items, OpeningDetails, UOM , #Temp1            
 WHERE Items.Product_Code *= OpeningDetails.Product_Code AND              
 OpeningDetails.Opening_Date = @FROMDATE      
 AND Items.UOM *= UOM.UOM And IsNull(Items.Active,0) = 1   
 And Items.CategoryID *= #Temp1.CatID  
   
  
end              
Else if @UOM = 'Conversion Factor'              
Begin              
Insert into #Temp2    
 SELECT Items.Product_Code,   
 "Item Code" = Items.Product_Code,   
 "Item Name" = ProductName,               
  
 "Conversion Units" = ConversionTable.ConversionUnit,   
 "Opening Quantity" = (ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) *   
 ISNULL(Items.ConversionFactor, 0),  
  
 "Free Opening Quantity" = IsNull(Free_Saleable_Quantity, 0) *   
 ISNULL(Items.ConversionFactor, 0),  
  
 "Damage Opening Quantity" = IsNull(Damage_Opening_Quantity, 0)  
 * ISNULL(Items.ConversionFactor, 0),  
  
 "Purchase" = (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0))   
 FROM GRNAbstract, GRNDetail               
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID   
 AND GRNDetail.Product_Code = Items.Product_Code   
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0), 0)   
 * ISNULL(Items.ConversionFactor, 0)),  
               
 "Sales Return" = (ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 4)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)   
 * ISNULL(Items.ConversionFactor, 0)),  
      
 "Issues" = ((ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 And InvoiceDetail.SalePrice <> 0), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0))   
 * ISNULL(Items.ConversionFactor, 0)),  
    
 "Ready Stock Sales" = ((IsNull((Select Sum(Quantity)  
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code And  
 IsNull(InvoiceAbstract.Status, 0) & 16 <> 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 (IsNull(InvoiceAbstract.Status, 0) & 128) = 0), 0)   
 * IsNull(Items.ConversionFactor, 0))),  
      
 "Order Booking" = (((IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 7 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 DispatchDetail.SalePrice <> 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 128) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0))  
 * IsNull(Items.ConversionFactor, 0))),  
      
 "Direct Sales" = ((IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)   
 + IsNull((Select Sum(Quantity) From InvoiceAbstract, InvoiceDetail  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceType = 2 And  
 InvoiceDetail.SalePrice <> 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 InvoiceDetail.Product_Code = Items.Product_Code), 0)))  
 * IsNull(Items.ConversionFactor, 0),  
  
 "Free Issues" = ((ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 And InvoiceDetail.SalePrice = 0), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice = 0), 0))   
 * ISNULL(Items.ConversionFactor, 0)),  
    
 "Purchase Return" = (ISNULL((SELECT SUM(Quantity)   
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract               
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code               
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(AdjustmentReturnAbstract.Status,0) & 64) = 0), 0)   
 * ISNULL(Items.ConversionFactor, 0)),  
                
 "Adjustments" = (ISNULL((SELECT SUM(Quantity - OldQty)   
 FROM StockAdjustment, StockAdjustmentAbstract   
 WHERE ISNULL(AdjustmentType,0) = 1 AND  
 Product_Code = Items.Product_Code   
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID              
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)   
 * ISNULL(Items.ConversionFactor, 0)),  
  
 "Stock Transfer Out" = (IsNull((select sum(quantity)   
 from stocktransferoutdetail,stocktransferoutabstract  
 where StockTransferOutDetail.Product_Code = Items.Product_Code  
 and stocktransferoutabstract.docserial = stocktransferoutdetail.docserial  
 and stocktransferoutabstract.documentdate between @fromdate and @todate),0)  
 * ISNULL(Items.ConversionFactor, 0)),  
  
 "Stock Transfer In" = (IsNull((select sum(quantity)   
 from stocktransferindetail,stocktransferinabstract  
 where StockTransferinDetail.Product_Code = Items.Product_Code  
 and stocktransferinabstract.docserial = stocktransferindetail.docserial  
 and stocktransferInabstract.documentdate between @fromdate and @todate),0)  
 * ISNULL(Items.ConversionFactor, 0)),  
  
 "On Hand Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))  
 end )  
 * ISNULL(Items.ConversionFactor, 0),  
   
 "On Hand Free Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0))  
 end)  
 * ISNULL(Items.ConversionFactor, 0),  
  
 "On Hand Damage Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)  
 end )  
 * ISNULL(Items.ConversionFactor, 0),  
 #Temp1.LevelID  
  
 FROM Items, OpeningDetails, ConversionTable ,#Temp1  
 WHERE Items.Product_Code *= OpeningDetails.Product_Code AND              
 OpeningDetails.Opening_Date = @FROMDATE              
 AND Items.ConversionUnit *= ConversionTable.ConversionID And IsNull(Items.Active,0) = 1   
 And Items.CategoryID *= #Temp1.CatID  
end              
else              
begin              
Insert into #Temp2    
 SELECT Items.Product_Code,   
 "Item Code" = Items.Product_Code,   
 "Item Name" = ProductName,               
 "Reporting UOM" =  UOM.Description,  
 "Opening Quantity" = (ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) /   
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END),  
  
 "Free Opening Quantity" = IsNull(Free_Saleable_Quantity, 0) /   
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0)   
 END),  
  
 "Damage Opening Quantity" = IsNull(Damage_Opening_Quantity, 0)  
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE ISNULL(Items.ReportingUnit, 0) END) ,  
  
 "Purchase" = (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0))   
 FROM GRNAbstract, GRNDetail               
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID   
 AND GRNDetail.Product_Code = Items.Product_Code   
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0), 0) /               
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0)   
 END)),  
               
 "Sales Return" = (ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 4)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0)   
 END)),  
      
 "Issues" = ((ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 And InvoiceDetail.SalePrice <> 0), 0) +   
 ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0))   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
    
 "Ready Stock Sales" = ((IsNull((Select Sum(Quantity)  
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 16 <> 0 And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 (IsNull(InvoiceAbstract.Status, 0) & 128) = 0), 0)   
 / (Case IsNull(Items.ReportingUnit, 0)   
 When 0 then   
 1   
 Else   
 IsNull(Items.ReportingUnit, 0)   
 End))),  
      
 "Order Booking" = (((IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 7 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.SalePrice <> 0 And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)   
 + ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 128) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice <> 0), 0))   
 / (Case IsNull(Items.ReportingUnit, 0)  
 When 0 then  
 1  
 Else  
 IsNull(Items.ReportingUnit, 0)  
 End))),  
      
 "Direct Sales" = ((IsNull((Select Sum(DispatchDetail.Quantity)   
 From DispatchAbstract, DispatchDetail, InvoiceAbstract  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And  
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 DispatchDetail.SalePrice <> 0 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 DispatchDetail.Product_Code = Items.Product_Code), 0)   
 + IsNull((Select Sum(Quantity) From InvoiceAbstract, InvoiceDetail  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
 IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And  
 InvoiceAbstract.InvoiceType = 2 And  
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
 InvoiceDetail.SalePrice <> 0 And  
 InvoiceDetail.Product_Code = Items.Product_Code), 0)))  
 / (Case IsNull(Items.ReportingUnit, 0)  
 When 0 then  
 1  
 Else  
 IsNull(Items.ReportingUnit, 0)  
 End),  
  
 "Free Issues" = ((ISNULL((SELECT SUM(Quantity)   
 FROM InvoiceDetail, InvoiceAbstract   
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 AND (InvoiceAbstract.InvoiceType = 2)   
 AND (InvoiceAbstract.Status & 128) = 0   
 AND InvoiceDetail.Product_Code = Items.Product_Code   
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
 And InvoiceDetail.SalePrice = 0), 0) +   
 ISNULL((SELECT SUM(Quantity)   
 FROM DispatchDetail, DispatchAbstract   
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 AND (DispatchAbstract.Status & 64) = 0   
 AND DispatchDetail.Product_Code = Items.Product_Code   
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE  
 And DispatchDetail.SalePrice = 0), 0))   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
       
 "Purchase Return" = (ISNULL((SELECT SUM(Quantity)   
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract               
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID   
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code               
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE  
 And (IsNull(AdjustmentReturnAbstract.Status,0) & 64) = 0), 0)   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
                
 "Adjustments" = (ISNULL((SELECT SUM(Quantity - OldQty)   
 FROM StockAdjustment, StockAdjustmentAbstract   
 WHERE ISNULL(AdjustmentType,0) = 1 AND  
 Product_Code = Items.Product_Code   
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID              
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) /   
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
  
 "Stock Transfer Out" = (IsNull((select sum(quantity)   
 from stocktransferoutdetail,stocktransferoutabstract  
 where StockTransferOutDetail.Product_Code = Items.Product_Code  
 and  stocktransferoutabstract.docserial = stocktransferoutdetail.docserial  
 and stocktransferoutabstract.documentdate between @fromdate and @todate),0)/  
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
  
 "Stock Transfer In" = (IsNull((select sum(quantity)   
 from stocktransferindetail,stocktransferinabstract  
 where StockTransferinDetail.Product_Code = Items.Product_Code  
 and  stocktransferinabstract.docserial = stocktransferindetail.docserial  
 and stocktransferinabstract.documentdate between @fromdate and @todate),0)/  
 (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
   
 "On Hand Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))  
 end   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
   
 "On Hand Free Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Free_Saleable_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 (ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +   
 (SELECT ISNULL(SUM(Pending), 0)   
 FROM VanStatementDetail, VanStatementAbstract   
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial   
 AND (VanStatementAbstract.Status & 128) = 0   
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0))  
 end   
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END)),  
  
 "On Hand Damage Qty" = (CASE   
 when (@TODATE < @NEXT_DATE) THEN   
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)  
 FROM OpeningDetails   
 WHERE OpeningDetails.Product_Code = Items.Product_Code   
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)  
 ELSE   
 ISNULL((SELECT SUM(Quantity)   
 FROM Batch_Products   
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)  
 end )  
 / (CASE ISNULL(Items.ReportingUnit, 0)   
 WHEN 0 THEN   
 1   
 ELSE   
 ISNULL(Items.ReportingUnit, 0) END),  
 #Temp1.LevelID  
  
 FROM Items, OpeningDetails, UOM , #Temp1            
 WHERE Items.Product_Code *= OpeningDetails.Product_Code AND              
 OpeningDetails.Opening_Date = @FROMDATE              
 AND Items.ReportingUOM *= UOM.UOM And IsNull(Items.Active,0) = 1   
 And Items.CategoryID = #Temp1.CatID  
  
end   

Insert into #temp2   
 Select '~', 'Total:',Space(1),Space(1), SUM(Opening_Quantity * Items.ConversionFactor), 
SUM(Free_Opening_Quantity * Items.ConversionFactor), SUM(Damage_Opening_Quantity * Items.ConversionFactor), 
SUM(Purchase * Items.ConversionFactor), SUM(Sales_Return * Items.ConversionFactor), 
SUM(Issues * Items.ConversionFactor), SUM(Ready_Stock_Sales * Items.ConversionFactor), 
SUM(Order_Booking * Items.ConversionFactor), SUM(Direct_Sales * Items.ConversionFactor), 
SUM(Free_Issues * Items.ConversionFactor), SUM(Purchase_Return * Items.ConversionFactor), 
SUM(Adjustments * Items.ConversionFactor), SUM(Stock_Transfer_Out * Items.ConversionFactor), 
SUM(Stock_Transfer_In * Items.ConversionFactor), SUM(On_Hand_Quantity * Items.ConversionFactor), 
SUM(On_Hand_Free_Quantity * Items.ConversionFactor), SUM(On_Hand_Damage_Quantity * Items.ConversionFactor), 
IsNull(LEVELID,0)+0.1 FROM #TEMP2,ITEMS WHERE #TEMP2.PRODUCT_CODE = ITEMS.PRODUCT_CODE GROUP BY LEVELID  
  
SELECT * FROM #TEMP2 Order BY LEVELID,Product_Code,Item_Code  
  
drop table #temp1  
drop table #temp2
