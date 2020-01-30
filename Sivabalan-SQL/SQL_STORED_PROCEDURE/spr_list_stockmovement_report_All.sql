CREATE procedure [dbo].[spr_list_stockmovement_report_All](@Mfr nvarchar(2550),      
      @Division nvarchar(2550), @UOM nvarchar(100), @StockVal nvarchar(100),  
      @FROMDATE datetime,      
      @TODATE datetime)      
as
declare @NEXT_DATE datetime        
DECLARE @CORRECTED_DATE datetime        

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)       
Create table #tmpMfr(Manufacturer nvarchar(255))  
Create table #tmpDiv(Division nvarchar(255))  

if @Mfr='%'   
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer  
Else  
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)  
  
if @Division='%'  
   Insert into #tmpDiv select BrandName from Brand  
Else  
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)  

SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/'         
+ CAST(DATEPART(mm, @TODATE) as nvarchar) + '/'         
+ cast(DATEPART(yyyy, @TODATE) AS nvarchar)        
SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS nvarchar) + '/'         
+ CAST(DATEPART(mm, GETDATE()) as nvarchar) + '/'         
+ cast(DATEPART(yyyy, GETDATE()) AS nvarchar)        
    
DECLARE @SQL nvarchar(1000)  
DECLARE @FirstLevel nvarchar(1000)  
DECLARE @LastLevel nvarchar(1000)  
  
 SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')
 SET @LastLevel= dbo.GetHierarchyColumn('LAST')

SELECT Items.CategoryID, Items.Product_Code, "Quantity" = Sum(ItemClosingStock.Quantity), ItemClosingStock.ClosingDate 
INTO #ItemsStockQty FROM ItemClosingStock, Items 
WHERE ItemClosingStock.ClosingDate BETWEEN DateAdd(d,-1,@FROMDATE)
AND @TODATE And Items.Product_Code = ItemClosingStock.Product_Code
GROUP BY CategoryID, ItemClosingStock.ClosingDate, Items.Product_Code

IF @UOM = 'Sales UOM'      
BEGIN    
 SELECT  Items.CategoryID, "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),    
 "Product Hierarchy Last Level" = ItemCategories.Category_Name,    

 "Opening Quantity" = (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
                      + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID), 
         
 "Opening Value" =     
 case @StockVal      
 When 'PTSS' Then                
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTS), 0))
 When 'PTS' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTR), 0))
 When 'ECP' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.ECP), 0))
 When 'PTR' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Company_Price), 0))
 Else    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Purchase_Price), 0))
 End,     
         
 "Purchase" = Cast(ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
 FROM GRNAbstract, GRNDetail  
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) As nvarchar),    
    
 "Purchase Value" =     
 ISNULL((SELECT SUM((QuantityReceived - QuantityRejected) * Isnull(Case @StockVal     
     When 'PTSS' Then a.PTS    
     When 'PTS' Then a.PTR    
     When 'ECP' Then a.ECP    
     When 'PTR' Then a.Company_Price    
     Else Purchase_Price End, 0))      
 FROM GRNAbstract, GRNDetail, Items a      
 WHERE GRNDetail.GRNID = GRNAbstract.GRNID      
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE       
 And (GRNAbstract.GRNStatus & 64) = 0      
 And (GRNAbstract.GRNStatus & 32) = 0     
 AND a.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0),    
         
 "Free Purchase" = Cast(ISNULL((SELECT SUM(IsNull(FreeQty, 0))         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) As nvarchar),    
         
 "Sales Return Saleable" = Cast(ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) As nvarchar),    
         
 "Sales Return Damages" = Cast(ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) As nvarchar),    
         
 "Total Issues" = ((ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
                      + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID)  +
 (SELECT IsNull(SUM(QuantityReceived - QuantityRejected),0)         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0) +
 (ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +
 ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) -
 ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) +
 ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) -
 cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)) +
 IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end),
         
 "Free Issues" = Cast(ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 2)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
 And InvoiceDetail.SalePrice = 0), 0)         
 + ISNULL((SELECT SUM(Quantity)         
 FROM DispatchDetail, DispatchAbstract         
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 AND (DispatchAbstract.Status & 64) = 0         
 AND DispatchDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
 And DispatchDetail.SalePrice = 0), 0) As nvarchar),    
         
 "Purchase Return" = Cast(ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) As nvarchar),    
         
 "Adjustments" = Cast(ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) As nvarchar),    
         
 "Stock Transfer Out" = Cast(IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) As nvarchar),    
         
 "Stock Transfer In" = Cast(IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) As nvarchar),    
         
 "Stock Destruction" = Cast(cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)) As nvarchar),    

 "On Hand Qty" = CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end,        

 "On Hand Value" = CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Value) - IsNull(Sum(Damage_Opening_Value), 0)        
 FROM OpeningDetails, Items Item         
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) + 
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)       
 ELSE         
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM Batch_Products b, items i        
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = i.Product_Code And i.CategoryID = Items.CategoryID And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +         
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM VanStatementDetail, VanStatementAbstract, items i  
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And i.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = i.Product_Code And VanStatementDetail.SalePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)              
 end,        
    
 "Pending Orders" = ((Select IsNull(Sum(Pending),0) From PODetail, POAbstract      
 Where POAbstract.PONumber = PODetail.PONumber And     
 PODate BETWEEN @FROMDATE AND @TODATE And (POAbstract.Status & 128) = 0      
 And PODetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And PODetail.Pending > 0) +     
 (Select IsNull(Sum(Pending),0) From Stock_Request_Abstract, Stock_Request_Detail       
Where Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And Pending > 0 And      
 Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number      
 And Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE    
 And (Stock_Request_Abstract.Status & 128) = 0))
         
 INTO #StockMovementSalesUOM FROM Items, OpeningDetails, Manufacturer, Brand, ItemCategories    
 WHERE Items.BrandID = Brand.BrandID And    
 Items.ManufacturerID = Manufacturer.ManufacturerID And      
 Items.CategoryID *= ItemCategories.CategoryID  And 
 Items.Product_Code = OpeningDetails.Product_Code And
 OpeningDetails.Opening_Date = @FROMDATE And
 Manufacturer.Manufacturer_Name In (Select Manufacturer From  #tmpMfr) And    
 Brand.BrandName In (Select * From  #tmpDiv)
GROUP BY ItemCategories.Category_Name, Items.CategoryID
  
SET @SQL = 'SELECT [CategoryID], [Product Hierarchy First Level] As "' + @FirstLevel +   
'", [Product Hierarchy Last Level] As "' +  @LastLevel + '", ' +   
'[Opening Quantity], [Opening Value], [Purchase], [Purchase Value], [Free Purchase], [Sales Return Saleable], ' +  
'[Sales Return Damages], [Total Issues], [Free Issues], [Purchase Return], [Adjustments], [Stock Transfer Out], ' +  
'[Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Value], [Pending Orders] FROM #StockMovementSalesUOM'  
  
EXEC(@SQL)  
  
DROP TABLE #StockMovementSalesUOM  
END    
  
ELSE IF @UOM = 'Conversion Factor'    
BEGIN    

 SELECT  Items.CategoryID, "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),    
 "Product Hierarchy Last Level" = ItemCategories.Category_Name,    

 "Opening Quantity" = Cast(((ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
                      + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID))
                      * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)), 
        
 "Opening Value" =     
 case @StockVal      
 When 'PTSS' Then                
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTS), 0))
 When 'PTS' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTR), 0))
 When 'ECP' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.ECP), 0))
 When 'PTR' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Company_Price), 0))
 Else    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Purchase_Price), 0))
 End,     
         
 "Purchase" = Cast((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
 FROM GRNAbstract, GRNDetail  
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0)) * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
    
 "Purchase Value" =     
 ISNULL((SELECT SUM((QuantityReceived - QuantityRejected) * Isnull(Case @StockVal     
     When 'PTSS' Then a.PTS    
     When 'PTS' Then a.PTR    
     When 'ECP' Then a.ECP    
    When 'PTR' Then a.Company_Price    
     Else Purchase_Price End, 0))      
 FROM GRNAbstract, GRNDetail, Items a      
 WHERE GRNDetail.GRNID = GRNAbstract.GRNID      
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE       
 And (GRNAbstract.GRNStatus & 64) = 0      
 And (GRNAbstract.GRNStatus & 32) = 0     
 AND a.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0),    
         
 "Free Purchase" = Cast((ISNULL((SELECT SUM(IsNull(FreeQty, 0))         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Sales Return Saleable" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Sales Return Damages" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Total Issues" = Cast((((ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
                      + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID)  +
 (SELECT IsNull(SUM(QuantityReceived - QuantityRejected),0)         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0) +
 (ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +
 ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) -
 ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) +
 ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) -
 cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)) +
 IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end)) * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),
         
 "Free Issues" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 2)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
 And InvoiceDetail.SalePrice = 0), 0)         
 + ISNULL((SELECT SUM(Quantity)         
 FROM DispatchDetail, DispatchAbstract         
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 AND (DispatchAbstract.Status & 64) = 0         
 AND DispatchDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
 And DispatchDetail.SalePrice = 0), 0)) * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Purchase Return" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Adjustments" = Cast((ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Stock Transfer Out" = Cast((IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0))
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Stock Transfer In" = Cast((IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0)) 
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    
         
 "Stock Destruction" = Cast((cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)))
 * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),    

 "On Hand Qty" = Cast((CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end) * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6)),        

 "On Hand Value" = CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Value) - IsNull(Sum(Damage_Opening_Value), 0)        
 FROM OpeningDetails, Items Item         
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) + 
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)       
 ELSE         
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM Batch_Products b, items i        
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = i.Product_Code And i.CategoryID = Items.CategoryID And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +         
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM VanStatementDetail, VanStatementAbstract, items i  
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And i.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = i.Product_Code And VanStatementDetail.SalePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)              
 end,        
    
 "Pending Orders" = Cast(((Select IsNull(Sum(Pending),0) From PODetail, POAbstract      
 Where POAbstract.PONumber = PODetail.PONumber And     
 PODate BETWEEN @FROMDATE AND @TODATE And (POAbstract.Status & 128) = 0      
 And PODetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And PODetail.Pending > 0) +     
 (Select IsNull(Sum(Pending),0) From Stock_Request_Abstract, Stock_Request_Detail       
 Where Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And Pending > 0 And      
 Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number      
 And Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE    
 And (Stock_Request_Abstract.Status & 128) = 0)) * IsNull(Sum(Items.ConversionFactor),0) As Decimal(18,6))
         
 INTO #StockMovementConversion FROM Items, OpeningDetails, Manufacturer, Brand, ItemCategories    
 WHERE Items.BrandID = Brand.BrandID And    
 Items.ManufacturerID = Manufacturer.ManufacturerID And      
 Items.CategoryID *= ItemCategories.CategoryID  And 
 Items.Product_Code = OpeningDetails.Product_Code And
 OpeningDetails.Opening_Date = @FROMDATE And
 Manufacturer.Manufacturer_Name In (Select Manufacturer From  #tmpMfr) And    
 Brand.BrandName In (Select * From #tmpDiv)
 GROUP BY ItemCategories.Category_Name, Items.CategoryID
  
SET @SQL = 'SELECT [CategoryID], [Product Hierarchy First Level] As "' + @FirstLevel +   
'", [Product Hierarchy Last Level] As "' +  @LastLevel + '", ' +   
'[Opening Quantity], [Opening Value], [Purchase], [Purchase Value], [Free Purchase], [Sales Return Saleable], ' +  
'[Sales Return Damages], [Total Issues], [Free Issues], [Purchase Return], [Adjustments], [Stock Transfer Out], ' +  
'[Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Value], [Pending Orders] FROM #StockMovementConversion'  
  
EXEC(@SQL)  
  
DROP TABLE #StockMovementConversion    
   
END    
ELSE    
BEGIN    

 SELECT  Items.CategoryID, "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID),    
 "Product Hierarchy Last Level" = ItemCategories.Category_Name,    

 "Opening Quantity" = Cast(((ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
                      + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID))
                       / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
			 WHEN 0 THEN       
			 1       
			 ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
			 AS Decimal(18,6)), 
        
 "Opening Value" =     
 case @StockVal      
 When 'PTSS' Then                
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTS), 0))
 When 'PTS' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.PTR), 0))
 When 'ECP' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.ECP), 0))
 When 'PTR' Then    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Company_Price), 0))
 Else    
 (IsNull((SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID),0) +
 (ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0)) * Isnull(Sum(Items.Purchase_Price), 0))
 End,     
         
 "Purchase" = Cast((ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)         
 FROM GRNAbstract, GRNDetail  
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0)) 
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
    
 "Purchase Value" =     
 ISNULL((SELECT SUM((QuantityReceived - QuantityRejected) * Isnull(Case @StockVal     
     When 'PTSS' Then a.PTS    
     When 'PTS' Then a.PTR    
     When 'ECP' Then a.ECP    
     When 'PTR' Then a.Company_Price    
     Else Purchase_Price End, 0))      
 FROM GRNAbstract, GRNDetail, Items a      
 WHERE GRNDetail.GRNID = GRNAbstract.GRNID      
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE       
 And (GRNAbstract.GRNStatus & 64) = 0      
 And (GRNAbstract.GRNStatus & 32) = 0     
 AND a.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0),    
         
 "Free Purchase" = Cast((ISNULL((SELECT SUM(IsNull(FreeQty, 0))         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0 ), 0)) 
 / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Sales Return Saleable" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) 
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Sales Return Damages" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) 
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Total Issues" = Cast((((ISNULL(Sum(Opening_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0) - IsNull(Sum(Free_Saleable_Quantity), 0))
            + (SELECT IsNull(Sum(Quantity), 0) FROM #ItemsStockQty WHERE ClosingDate = DateAdd(d,-1,@FROMDATE) And CategoryID = Items.CategoryID)  +
 (SELECT IsNull(SUM(QuantityReceived - QuantityRejected),0)         
 FROM GRNAbstract, GRNDetail         
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID         
 AND GRNDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And         
 (GRNAbstract.GRNStatus & 64) = 0 And        
 (GRNAbstract.GRNStatus & 32) = 0) +
 (ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) = 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) +
 ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 4)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND (InvoiceAbstract.Status & 32) <> 0        
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)) -
 ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) +
 ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) -
 cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)) +
 IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) -
 CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end))  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),
         
 "Free Issues" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract         
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 AND (InvoiceAbstract.InvoiceType = 2)         
 AND (InvoiceAbstract.Status & 128) = 0         
 AND InvoiceDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
 And InvoiceDetail.SalePrice = 0), 0)         
 + ISNULL((SELECT SUM(Quantity)         
 FROM DispatchDetail, DispatchAbstract         
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 AND (DispatchAbstract.Status & 64) = 0         
 AND DispatchDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE        
 And DispatchDetail.SalePrice = 0), 0))  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Purchase Return" = Cast((ISNULL((SELECT SUM(Quantity)         
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract         
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID         
 AND AdjustmentReturnDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)         
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE     
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) 
 / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Adjustments" = Cast((ISNULL((SELECT SUM(Quantity - OldQty)         
 FROM StockAdjustment, StockAdjustmentAbstract         
 WHERE ISNULL(AdjustmentType,0) = 1         
 And StockAdjustment.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID        
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) 
 / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN   
  1      
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Stock Transfer Out" = Cast((IsNull((Select Sum(Quantity)         
 From StockTransferOutAbstract, StockTransferOutDetail        
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial        
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferOutAbstract.Status & 192 = 0        
 And StockTransferOutDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0))
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Stock Transfer In" = Cast((IsNull((Select Sum(Quantity)         
 From StockTransferInAbstract, StockTransferInDetail         
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial        
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate         
 And StockTransferInAbstract.Status & 192 = 0        
 And StockTransferInDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0)) 
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    
         
 "Stock Destruction" = Cast((cast(IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                 
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote     
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID    
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                 
 And ClaimsNote.Status & 1 <> 0        
 And StockDestructionDetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID)), 0) as Decimal(18,6)))
  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),    

 "On Hand Qty" = Cast((CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Quantity) - IsNull(Sum(Free_Saleable_Quantity), 0) - IsNull(Sum(Damage_Opening_Quantity), 0)        
 FROM OpeningDetails, Items Item        
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID        
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)  
 ELSE       
 (ISNULL((SELECT SUM(Quantity)         
 FROM Batch_Products, Items Item                 
 WHERE Batch_Products.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID 
 And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +        
 (SELECT ISNULL(SUM(Pending), 0)         
 FROM VanStatementDetail, VanStatementAbstract, Items Item         
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And Item.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = Item.Product_Code And VanStatementDetail.PurchasePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity), 0) FROM #ItemsStockQty
 WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And CategoryID = Items.CategoryID)        
 end)  / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6)),        

 "On Hand Value" = CASE         
 when (@TODATE < @NEXT_DATE) THEN         
 ISNULL((Select Sum(Opening_Value) - IsNull(Sum(Damage_Opening_Value), 0)        
 FROM OpeningDetails, Items Item     
 WHERE OpeningDetails.Product_Code = Item.Product_Code And Item.CategoryID = Items.CategoryID
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) + 
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)       
 ELSE      
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM Batch_Products b, items i        
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = i.Product_Code And i.CategoryID = Items.CategoryID And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +         
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)         
 FROM VanStatementDetail, VanStatementAbstract, items i  
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial         
 AND (VanStatementAbstract.Status & 128) = 0 And i.CategoryID = Items.CategoryID        
 And VanStatementDetail.Product_Code = i.Product_Code And VanStatementDetail.SalePrice <> 0)) +
 (SELECT ISNULL(Sum(Quantity) * (CASE @StockVal
	When 'PTSS' Then Sum(Items.PTS)
        When 'PTS' Then Sum(Items.PTR)
        When 'ECP' Then Sum(Items.ECP)
	When 'PTR' Then Sum(Items.Company_Price)
        Else Sum(Items.Purchase_Price) End), 0) FROM #ItemsStockQty 
  WHERE ClosingDate = dbo.StripDateFromTime(@TODATE) And #ItemsStockQty.CategoryID = Items.CategoryID)              
 end,        
    
 "Pending Orders" = Cast(((Select IsNull(Sum(Pending),0) From PODetail, POAbstract      
 Where POAbstract.PONumber = PODetail.PONumber And     
 PODate BETWEEN @FROMDATE AND @TODATE And (POAbstract.Status & 128) = 0      
 And PODetail.Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And PODetail.Pending > 0) +     
 (Select IsNull(Sum(Pending),0) From Stock_Request_Abstract, Stock_Request_Detail       
 Where Product_Code IN (SELECT Item.Product_Code FROM Items Item WHERE Item.CategoryID = Items.CategoryID) And Pending > 0 And      
 Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number      
 And Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE    
 And (Stock_Request_Abstract.Status & 128) = 0)) 
   / (CASE ISNULL(Sum(Items.ReportingUnit), 0)       
  WHEN 0 THEN       
  1       
  ELSE ISNULL(Sum(Items.ReportingUnit), 0) END)       
  AS Decimal(18,6))
         
 INTO #StockMovementReportUOM FROM Items, OpeningDetails, Manufacturer, Brand, ItemCategories    
 WHERE Items.BrandID = Brand.BrandID And    
 Items.ManufacturerID = Manufacturer.ManufacturerID And      
 Items.CategoryID *= ItemCategories.CategoryID  And 
 Items.Product_Code = OpeningDetails.Product_Code And
 OpeningDetails.Opening_Date = @FROMDATE And
 Manufacturer.Manufacturer_Name In (Select Manufacturer From #tmpMfr) And    
 Brand.BrandName In (Select * From #tmpDiv )
 GROUP BY ItemCategories.Category_Name, Items.CategoryID

SET @SQL = 'SELECT [CategoryID], [Product Hierarchy First Level] As "' + @FirstLevel +   
'", [Product Hierarchy Last Level] As "' +  @LastLevel + '", ' +   
'[Opening Quantity], [Opening Value], [Purchase], [Purchase Value], [Free Purchase], [Sales Return Saleable], ' +  
'[Sales Return Damages], [Total Issues], [Free Issues], [Purchase Return], [Adjustments], [Stock Transfer Out], ' +  
'[Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Value], [Pending Orders] FROM #StockMovementReportUOM '  
  
EXEC(@SQL)  
DROP TABLE #StockMovementReportUOM    
DROP TABLE  #tmpMfr
DROP TABLE #tmpDiv

END
