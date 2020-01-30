CREATE procedure [dbo].[spr_list_stockmovement_report_34](@HierarchyName nvarchar(255),        
        @UOM nvarchar(50),        
        @FROMDATE datetime,        
        @TODATE datetime)        
as                      
Declare @TOTAL As NVarchar(50)
Set @TOTAL  = dbo.LookupDictionaryItem(N'Total:',Default)
         
declare @Level int          
set @level = (Select HierarchyId from Itemhierarchy where HierarchyName = @HierarchyName)          
          
create table #Temp1(CatID int, LevelID int)          
          
Exec Spr_GetLevel @Level          
          
CREATE table #Temp2(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,Item_Code nvarchar(30),Item_Name nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,UOM nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,          
Active int,
Opening_Quantity decimal(20,6),Free_Opening_Quantity decimal(20,6),Damage_Opening_Quantity decimal(20,6),          
Purchase decimal(20,6), Free_Purchase decimal(20,6), Sales_Return decimal(20,6), Sales_Return_Damages decimal(20,6), Issues decimal(20,6),          
Ready_Stock_Sales decimal(20,6),Order_Booking decimal(20,6),Direct_Sales decimal(20,6),          
Free_Issues decimal(20,6),Purchase_Return decimal(20,2),Adjustments decimal(20,6),          
Stock_Transfer_Out decimal(20,6),Stock_Transfer_In decimal(20,6), 
Stock_Destruction decimal(20,6), On_Hand_Quantity decimal(20,6),          
On_Hand_Free_Quantity decimal(20,6),On_Hand_Damage_Quantity decimal(20,6),LevelID Decimal(18,6))          
          
declare @NEXT_DATE datetime                      
DECLARE @CORRECTED_DATE datetime                      
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS nvarchar)                      
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/' 
+ CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/' 
+ cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)           
          
if @UOM = 'Sales UOM'                        
 begin                      
 Insert into #Temp2      
 SELECT  distinct(Items.Product_Code),          
 "Item Code" = Items.Product_Code,           
 "Item Name" = ProductName,         
 "Sales UOM" = UOM.Description,            
 "Active" = Items.Active,
 "Opening Quantity" = ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0),           
 "Free Opening Quantity" = ISNULL(Free_Saleable_Quantity, 0),          
 "Damage Opening Quantity" = ISNULL(Damage_Opening_Quantity, 0),          
 "Purchase" = ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
 FROM GRNAbstract, GRNDetail                     
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND         
 GRNDetail.Product_Code = Items.Product_Code AND         
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And   
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And  
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0),        
              
 "Free Purchase" = ISNULL((SELECT SUM(IsNull(FreeQty,0))         
 FROM GRNAbstract, GRNDetail                     
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND         
 GRNDetail.Product_Code = Items.Product_Code AND         
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And   
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And  
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0),        
         
 "Sales Return Saleable" = ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code = Items.Product_Code         
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),        
                      
 "Sales Return Damages" = ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0     
 AND InvoiceDetail.Product_Code = Items.Product_Code         
 AND (InvoiceAbstract.Status & 32) <> 0        
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
 (IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 or IsNull(InvoiceAbstract.Status, 0) = 0 or IsNull(InvoiceAbstract.Status, 0) = 32) And   
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
                 
 "Adjustments" = ISNULL((SELECT SUM(Case AdjustmentType When 1 Then Quantity - OldQty Else Quantity End)         
 FROM StockAdjustment, StockAdjustmentAbstract        
 WHERE IsNull(AdjustmentType,0) = 1 And Product_Code = Items.Product_Code AND         
   
 StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                   
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0),        
   
 "Stock Transfer Out" = (IsNull((select sum(quantity)           
 from stocktransferoutdetail,stocktransferoutabstract          
 where stocktransferoutabstract.docserial = stocktransferoutdetail.docserial          
 and stocktransferoutabstract.documentdate between @fromdate and @todate          
 and IsNull(StockTransferOutAbstract.Status, 0) & 192 = 0  
 and StockTransferOutDetail.Product_Code = Items.Product_Code), 0)),          
   
 "Stock Transfer In" = (IsNull((select sum(quantity)           
 from stocktransferindetail,stocktransferinabstract          
 where stocktransferinabstract.docserial = stocktransferindetail.docserial          
 And StockTransferInAbstract.Status & 192 = 0  
 and stocktransferinabstract.documentdate between @fromdate and @todate          
 and StockTransferinDetail.Product_Code = Items.Product_Code), 0)),          
    
 "Stock Destruction" = (IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)             
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote 
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial            
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate             
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0)),

           
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
 AND Items.UOM *= UOM.UOM --And IsNull(Items.Active,0) = 1           
 And Items.CategoryID *= #Temp1.CatID          
                
end                      
Else if @UOM = 'Reporting UOM'                          
begin                        
 Insert into #Temp2        
 SELECT  distinct(Items.Product_Code),            
 "Item Code" = Items.Product_Code,             
 "Item Name" = ProductName,           
 "Sales UOM" = UOM.Description,              
 "Active" = Items.Active,
 "Opening Quantity" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code,ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)),             
 "Free Opening Quantity" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL(Free_Saleable_Quantity, 0)),            
 "Damage Opening Quantity" = ISNULL(Damage_Opening_Quantity, 0),            
 "Purchase" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)           
 FROM GRNAbstract, GRNDetail                       
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND           
 GRNDetail.Product_Code = Items.Product_Code AND           
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And     
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And    
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)),          
                
 "Free Purchase" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code,ISNULL((SELECT SUM(IsNull(FreeQty,0))           
 FROM GRNAbstract, GRNDetail                       
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND           
 GRNDetail.Product_Code = Items.Product_Code AND           
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And     
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And    
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)),          
           
 "Sales Return Saleable" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code,ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)),          
                        
 "Sales Return Damages" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code,ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0       
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)),          
                        
 "Issues" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,(ISNULL((SELECT SUM(Quantity)             
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
 And DispatchDetail.SalePrice <> 0), 0))),            
            
 "Ready Stock Sales" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (IsNull((Select Sum(Quantity)            
 From DispatchAbstract, DispatchDetail, InvoiceAbstract            
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And            
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And            
 IsNull(InvoiceAbstract.Status, 0) & 16 <> 0 And            
 InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And            
 DispatchDetail.SalePrice <> 0 And            
 DispatchDetail.Product_Code = Items.Product_Code And            
 (IsNull(InvoiceAbstract.Status, 0) & 128) = 0), 0))),            
         
 "Order Booking" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code,(IsNull((Select Sum(DispatchDetail.Quantity)             
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
 And DispatchDetail.SalePrice <> 0), 0))),            
     
 "Direct Sales" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (IsNull((Select Sum(DispatchDetail.Quantity)             
 From DispatchAbstract, DispatchDetail, InvoiceAbstract            
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID And            
 DispatchAbstract.InvoiceID = InvoiceAbstract.InvoiceID And            
 (IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 or IsNull(InvoiceAbstract.Status, 0) = 0 or IsNull(InvoiceAbstract.Status, 0) = 32) And     
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
 InvoiceDetail.Product_Code = Items.Product_Code), 0))),            
     
 "Free Issues" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (ISNULL((SELECT SUM(Quantity)             
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
 And DispatchDetail.SalePrice = 0), 0))),           
                
 "Purchase Return" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, ISNULL((SELECT SUM(Quantity)             
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract             
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID             
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                 
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE            
 And (IsNull(AdjustmentReturnAbstract.Status,0) & 64) = 0), 0)),            
                   
 "Adjustments" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,ISNULL((SELECT SUM(Case AdjustmentType When 1 Then Quantity - OldQty Else Quantity End)           
 FROM StockAdjustment, StockAdjustmentAbstract          
 WHERE IsNull(AdjustmentType,0) = 1 And Product_Code = Items.Product_Code AND           
     
 StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                     
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)),          
     
 "Stock Transfer Out" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,(IsNull((select sum(quantity)             
 from stocktransferoutdetail,stocktransferoutabstract            
 where stocktransferoutabstract.docserial = stocktransferoutdetail.docserial            
 and stocktransferoutabstract.documentdate between @fromdate and @todate            
 and IsNull(StockTransferOutAbstract.Status, 0) & 192 = 0    
 and StockTransferOutDetail.Product_Code = Items.Product_Code), 0))),            
     
 "Stock Transfer In" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (IsNull((select sum(quantity)             
 from stocktransferindetail,stocktransferinabstract            
 where stocktransferinabstract.docserial = stocktransferindetail.docserial            
 And StockTransferInAbstract.Status & 192 = 0    
 and stocktransferinabstract.documentdate between @fromdate and @todate            
 and StockTransferinDetail.Product_Code = Items.Product_Code), 0))),            
      
 "Stock Destruction" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, (IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)               
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote   
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial              
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID  
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate               
 And ClaimsNote.Status & 1 <> 0          
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0))),  
  
             
 "On Hand Qty" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, CASE             
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0)) end),
      
 "On Hand Free Qty" = dbo.sp_Get_ReportingUOMQty(Items.Product_Code,CASE             
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice = 0)) end),            
     
 "On Hand Damage Qty" =dbo.sp_Get_ReportingUOMQty(Items.Product_Code, CASE             
 when (@TODATE < @NEXT_DATE) THEN             
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)            
 FROM OpeningDetails         
 WHERE OpeningDetails.Product_Code = Items.Product_Code             
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)            
 ELSE             
 (ISNULL((SELECT SUM(Quantity)             
 FROM Batch_Products             
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end),            
      
 #Temp1.LevelID            
 FROM Items, OpeningDetails, UOM , #Temp1                      
 WHERE Items.Product_Code *= OpeningDetails.Product_Code AND                        
 OpeningDetails.Opening_Date = @FROMDATE                
 AND Items.ReportingUOM *= UOM.UOM   
-- And IsNull(Items.Active,0) = 1             
 And Items.CategoryID *= #Temp1.CatID                               
end   
Else if @UOM = 'Conversion Factor'                        
Begin                        
 Insert into #Temp2              
 SELECT distinct(Items.Product_Code),             
 "Item Code" = Items.Product_Code,             
 "Item Name" = ProductName,                         
     
 "Conversion Units" = ConversionTable.ConversionUnit,             
 "Active" = Items.Active,
 "Opening Quantity" = (ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) *             
 ISNULL(Items.ConversionFactor, 0),            
     
 "Free Opening Quantity" = IsNull(Free_Saleable_Quantity, 0) *             
 ISNULL(Items.ConversionFactor, 0),            
     
 "Damage Opening Quantity" = IsNull(Damage_Opening_Quantity, 0)            
 * ISNULL(Items.ConversionFactor, 0),            
     
 "Purchase" = (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)             
 FROM GRNAbstract, GRNDetail                        
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
 AND GRNDetail.Product_Code = Items.Product_Code             
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And     
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And    
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)    
 * ISNULL(Items.ConversionFactor, 0)),            
                  
 "Free Purchase" = ISNULL((SELECT SUM(IsNull(FreeQty,0))           
 FROM GRNAbstract, GRNDetail                       
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND           
 GRNDetail.Product_Code = Items.Product_Code AND           
 GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE  And     
 (IsNull(GRNAbstract.GRNStatus, 0) & 64) = 0 And    
 (IsNull(GRNAbstract.GRNStatus, 0) & 32) = 0), 0)    
 * ISNULL(Items.ConversionFactor, 0),          
     
 "Sales Return Saleable" = (ISNULL((SELECT SUM(Quantity)             
 FROM InvoiceDetail, InvoiceAbstract             
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID             
 AND (InvoiceAbstract.InvoiceType = 4)             
 AND (InvoiceAbstract.Status & 128) = 0             
 AND InvoiceDetail.Product_Code = Items.Product_Code             
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)      
 * ISNULL(Items.ConversionFactor, 0)),            
         
 "Sales Return Damages" = ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) * ISNULL(Items.ConversionFactor, 0),          
     
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
 (IsNull(InvoiceAbstract.Status, 0) & 8 <> 0 or IsNull(InvoiceAbstract.Status, 0) = 0 or IsNull(InvoiceAbstract.Status, 0) = 32) And     
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
                   
 "Adjustments" = (ISNULL((SELECT SUM(Case AdjustmentType When 1 Then Quantity - OldQty Else Quantity End)           
 FROM StockAdjustment, StockAdjustmentAbstract           
 WHERE IsNull(AdjustmentType,0) = 1 And Product_Code = Items.Product_Code           
     
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                      
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)           
 * ISNULL(Items.ConversionFactor, 0)),          
     
 "Stock Transfer Out" = (IsNull((select sum(quantity)             
 from stocktransferoutdetail,stocktransferoutabstract            
 where StockTransferOutDetail.Product_Code = Items.Product_Code            
 and stocktransferoutabstract.docserial = stocktransferoutdetail.docserial            
 and IsNull(StockTransferOutAbstract.Status, 0) & 192 = 0    
 and stocktransferoutabstract.documentdate between @fromdate and @todate),0)            
 * ISNULL(Items.ConversionFactor, 0)),            
     
 "Stock Transfer In" = (IsNull((select sum(quantity)             
 from stocktransferindetail,stocktransferinabstract            
 where StockTransferinDetail.Product_Code = Items.Product_Code            
 and stocktransferinabstract.docserial = stocktransferindetail.docserial            
 And StockTransferInAbstract.Status & 192 = 0    
 and stocktransferInabstract.documentdate between @fromdate and @todate),0)            
 * ISNULL(Items.ConversionFactor, 0)),            
     
 "Stock Destruction" = (IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)               
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote   
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial              
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID  
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate               
 And ClaimsNote.Status & 1 <> 0      
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0)),  
  
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
 AND Items.ConversionUnit *= ConversionTable.ConversionID --And IsNull(Items.Active,0) = 1             
 And Items.CategoryID *= #Temp1.CatID            
end                        
if (@UOM = 'Conversion Factor'  or @UOM ='Sales UOM' or @UOM ='Reporting UOM')                      
Begin      
 Insert into #temp2             
 Select '~', 'Total:',Space(1),Space(1),1, SUM(Opening_Quantity),SUM(Free_Opening_Quantity),     
 SUM(Damage_Opening_Quantity),SUM(Purchase), SUM(Free_Purchase),SUM(Sales_Return),     
 SUM(Sales_Return_Damages),SUM(Issues), SUM(Ready_Stock_Sales),SUM(Order_Booking),     
 SUM(Direct_Sales),SUM(Free_Issues), SUM(Purchase_Return),SUM(Adjustments),SUM(Stock_Transfer_Out),    
 SUM(Stock_Transfer_In), SUM(Stock_Destruction), SUM(On_Hand_Quantity),SUM(On_Hand_Free_Quantity), SUM(On_Hand_Damage_Quantity),    
 IsNull(LEVELID,0)+0.1 FROM #TEMP2,ITEMS WHERE #TEMP2.PRODUCT_CODE collate SQL_Latin1_General_Cp1_CI_AS = ITEMS.PRODUCT_CODE GROUP BY LEVELID            
end                       
select product_code,  
"Item Code" = Item_Code,   
"Item Name" = Item_Name,   
"UOM" = UOM,   
"Opening Quantity" = Opening_Quantity,   
"Free Opening Quantity" = Free_Opening_Quantity ,  
"Damage Opening Quantity" = Damage_Opening_Quantity ,  
"Purchase" = Purchase ,  
"Free Purchase" = Free_Purchase ,  
"Sales Return Saleable" = Sales_Return ,  
"Sales Return Damages" = Sales_Return_Damages ,  
"Issues" = Issues ,  
"Ready Stock Sales" = Ready_Stock_Sales ,  
"Order Booking" = Order_Booking ,  
"Direct Sales" = Direct_Sales ,  
"Free Issues" = Free_Issues ,  
"Purchase Return" = Purchase_Return ,  
"Adjustments" = Adjustments ,  
"Stock Transfer Out" = Stock_Transfer_Out ,  
"Stock Transfer In" = Stock_Transfer_In ,  
"Stock Destruction" = Stock_Destruction,
"On Hand Qty" = On_Hand_Quantity ,  
"On Hand Free Qty" = On_Hand_Free_Quantity ,  
"On Hand Damage Qty" = On_Hand_Damage_Quantity   
FROM #TEMP2 
Where isnull(Active,0) = 1 or (IsNull(Active,0) = 0 And
(Opening_Quantity <> 0 or Free_Opening_Quantity <> 0 or
Damage_Opening_Quantity <> 0 or Purchase <> 0 or
Free_Purchase <> 0 or Sales_Return <> 0 or
Sales_Return_Damages <> 0 or Issues <> 0 or
Ready_Stock_Sales <> 0 or Order_Booking <> 0 or
Direct_Sales <> 0 or Free_Issues <> 0 or
Purchase_Return <> 0 or Adjustments <> 0 or
Stock_Transfer_Out <> 0 or Stock_Transfer_In <> 0 or
Stock_Destruction <> 0 or On_Hand_Quantity <> 0 or
On_Hand_Free_Quantity <> 0 or On_Hand_Damage_Quantity <> 0))
Order BY LEVELID,Product_Code,Item_Code   

drop table #temp1  
drop table #temp2
