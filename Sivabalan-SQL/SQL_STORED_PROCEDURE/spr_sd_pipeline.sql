CREATE procedure [dbo].[spr_sd_pipeline](@Mfr nvarchar(2550),          
      @Division nvarchar(2550),      
      @FROMDATE datetime,          
      @TODATE datetime,    
      @UOM nvarchar(20),    
      @StockVal nvarchar(20))    
as          
begin    
declare @NEXT_DATE datetime          
DECLARE @CORRECTED_DATE datetime     
declare @FirstLevel nvarchar(50)  
declare @LastLevel nvarchar(50)  
declare @Query nvarchar(2000)  
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    

Set @StockVal = dbo.LookupDictionaryItem2(@StockVal, Default)

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
SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')  
SET @LastLevel= dbo.GetHierarchyColumn('LAST')  
    
if upper(@UOM) = 'SALES UOM'    
BEGIN    
 SELECT  Items.Product_Code,           
 "FLevel" =  dbo.fn_FirstLevelCategory(items.categoryid),    
 "LLevel" = ItemCategories.Category_Name,      
 "Item Code" = Items.Product_Code,           
 "Item Name" = ProductName,           
 "Sales UOM" = uom.description,          
 "Opening Quantity" = (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)),           
           
 "Free Opening Quantity" = ISNULL(Free_Saleable_Quantity, 0),           
           
 "Damage Opening Quantity" = ISNULL(Damage_Opening_Quantity, 0),          
           
 "Total Opening Quantity" = ISNULL(Opening_Quantity, 0),          
  
 "Opening Value" = case @StockVal     
 when 'PTSS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTS    
 when 'PTS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTR    
 when 'ECP' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*ECP    
 when 'PTR' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*company_price    
 end,    
           
 "Damage Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Damage_Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Damage_Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Damage_Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Damage_Opening_Quantity, 0)*company_price     
 end,    
    
 "Total Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Opening_Quantity, 0)*company_price     
 end,    
           
 "Purchase" = ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0),          
           
 "Free Purchase" = ISNULL((SELECT SUM(IsNull(FreeQty, 0))           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0),          
           
 "Purchase Value (%c)" = ISNULL((SELECT SUM((QuantityReceived - QuantityRejected)    
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM GRNAbstract, GRNDetail , items i           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 and items.Product_Code = i.product_code    
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0),          
  
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
    
 "Sales Return Saleable Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0) end)    
 FROM InvoiceDetail, InvoiceAbstract, items i           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
           
 "Sales Return Damages Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0) end)    
 FROM InvoiceDetail, InvoiceAbstract, items i    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
           
 "Total Issues" = (ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 2)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)           
 + ISNULL((SELECT SUM(Quantity)           
 FROM DispatchDetail, DispatchAbstract           
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
 AND Isnull(DispatchAbstract.Status, 0) & 64 = 0        
 AND DispatchDetail.Product_Code = Items.Product_Code           
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)),          
  
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
  
 "Sales Value (%c)" =    
 ISNULL((SELECT SUM((case invoicetype when 4 then 0 - InvoiceDetail.Quantity else InvoiceDetail.Quantity end)    
 * case invoicedetail.saleprice when 0 then 0 else  
   isnull(Case @StockVal     
    When 'PTSS' Then i.PTS     
    when 'PTS' then i.PTR     
    when 'ECP' then i.ECP     
    when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, Items i    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = i.Product_Code    
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),  
           
 "Purchase Return" = ISNULL((SELECT SUM(Quantity)           
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),          
           
 "Purchase Return Value (%c)" = ISNULL((SELECT SUM(Quantity           
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, items i    
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID           
 AND AdjustmentReturnDetail.Product_Code = i.Product_Code           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),          
           
 "Adjustments" = ISNULL((SELECT SUM(Quantity - OldQty)           
 FROM StockAdjustment, StockAdjustmentAbstract           
 WHERE ISNULL(AdjustmentType,0) = 1           
 And Product_Code = Items.Product_Code           
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0),          
           
 "Stock Transfer Out" = IsNull((Select Sum(Quantity)           
 From StockTransferOutAbstract, StockTransferOutDetail          
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial          
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferOutAbstract.Status & 192 = 0          
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0),          
           
 "Stock Transfer In" = IsNull((Select Sum(Quantity)           
 From StockTransferInAbstract, StockTransferInDetail           
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferInAbstract.Status & 192 = 0          
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0),          
           
 "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
 And ClaimsNote.Status & 1 <> 0          
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),      
       
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice <> 0))          
 end,          
           
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))          
 end,          
           
 "On Hand Damage Qty" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))          
 end,          
           
 "Total On Hand Qty" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Quantity          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code), 0) +          
 (SELECT ISNULL(SUM(Pending), 0)           
 FROM VanStatementDetail, VanStatementAbstract           
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code))          
 end,          
           
 "On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract, items i    
 WHERE Items.Product_Code = i.product_code and VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))          
 end,          
           
 "On Hand Damages Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Value, 0)    
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE        
 (SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i    
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)          
 end,           
           
 "Total On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value     
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code and items.product_code = openingdetails.product_code    
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract , items i          
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code and i.product_code = Items.Product_Code))          
 end,       
/* "Pending Orders" = IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
 IsNull(dbo.GetSRPending(Items.Product_Code), 0),    */  
  
"Pending Orders" = ((Select IsNull(Sum(Pending),0) From PODetail, POAbstract    
Where POAbstract.PONumber = PODetail.PONumber And   
dbo.stripdatefromtime(PODate) BETWEEN @FROMDATE AND @TODATE And (POAbstract.Status & 128) = 0    
And PODetail.Product_Code = Items.Product_Code And PODetail.Pending > 0) +   
(Select IsNull(Sum(Pending),0) From Stock_Request_Abstract, Stock_Request_Detail     
Where Product_Code = Items.Product_Code And Pending > 0 And    
Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number    
And Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE  
And (Stock_Request_Abstract.Status & 128) = 0)),  
  
       
 "Forum Code" = Items.Alias      
           
 into #SDPipeline           
 FROM Items, OpeningDetails, UOM, Manufacturer, Brand, ItemCategories      
 WHERE  items.uom *= uom.uom and Items.Product_Code *= OpeningDetails.Product_Code AND        
  OpeningDetails.Opening_Date = @FROMDATE        
  AND Items.UOM *= UOM.UOM And        
 Items.ManufacturerID = Manufacturer.ManufacturerID And        
  Manufacturer.Manufacturer_Name In (Select Manufacturer From #TmpMfr) And      
  Items.BrandID = Brand.BrandID And      
  Brand.BrandName In ( Select Division From #TmpDiv) And Items.CategoryID = ItemCategories.CategoryID      
 set @Query =  N'select [Item Code], [Item Name], [FLevel] as ['+@FirstLevel+'], [LLevel] as ['+@LastLevel+'], [Sales UOM], [Opening Quantity],  
 [Free Opening Quantity], [Damage Opening Quantity], [Total Opening Quantity], [Opening Value], [Damage Opening Value],   
 [Total Opening Value], [Purchase], [Free Purchase], [Sales Return Saleable], [Sales Return Damages], [Total Issues],  
 [Free Issues], [Sales Value (%c)], [Purchase Value (%c)], [Sales Return Saleable Value (%c)],   
 [Sales Return Damages Value (%c)], [Purchase Return Value (%c)], [Purchase Return], [Adjustments], [Stock Transfer Out],  
 [Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Free Qty], [On Hand Damage Qty], [Total On Hand Qty],   
 [On Hand Value], [On Hand Damages Value], [Total On Hand Value], [Pending Orders], [Forum Code]  
   from #SDPipeline'  
 exec sp_executesql @Query  
 drop table #SDPipeline  
END    
else if upper(@UOM) = 'CONVERSION FACTOR'    
begin    
 SELECT  Items.Product_Code,           
 "FLevel" =  dbo.fn_FirstLevelCategory(items.categoryid),    
 "LLevel" = ItemCategories.Category_Name,      
 "Item Code" = Items.Product_Code,           
 "Item Name" = ProductName,           
 "Conversion Factor" = ConversionTable.ConversionUnit,          
 "Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),           
           
 "Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),           
           
 "Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0)  * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
     
"Opening Value" = case @StockVal     
 when 'PTSS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTS    
 when 'PTS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTR    
 when 'ECP' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*ECP    
 when 'PTR' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*company_price    
 end,    
           
 "Damage Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Damage_Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Damage_Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Damage_Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Damage_Opening_Quantity, 0)*company_price     
 end,    
    
 "Total Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Opening_Quantity, 0)*company_price     
 end,    
           
 "Purchase" = cast (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Free Purchase" = cast (ISNULL((SELECT SUM(IsNull(FreeQty, 0))           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Purchase Value (%c)" = ISNULL((SELECT SUM((QuantityReceived - QuantityRejected)     
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM GRNAbstract, GRNDetail , items i           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 and items.Product_Code = i.product_code    
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) ,          
           
 "Sales Return Saleable" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Sales Return Damages" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Sales Return Saleable Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID          
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) ,          
           
 "Sales Return Damages Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
           
 "Total Issues" = cast(ISNULL((SELECT SUM(Quantity)         
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 2)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6))           
 + cast(ISNULL((SELECT SUM(Quantity)           
 FROM DispatchDetail, DispatchAbstract           
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
 AND Isnull(DispatchAbstract.Status, 0) & 64 = 0        
 AND DispatchDetail.Product_Code = Items.Product_Code           
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Free Issues" = cast(ISNULL((SELECT SUM(Quantity)     
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 2)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE          
 And InvoiceDetail.SalePrice = 0), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6))           
 + cast(ISNULL((SELECT SUM(Quantity)           
 FROM DispatchDetail, DispatchAbstract           
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
 AND (DispatchAbstract.Status & 64) = 0           
 AND DispatchDetail.Product_Code = Items.Product_Code           
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
 And DispatchDetail.SalePrice = 0), 0)* ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Sales Value (%c)" = ISNULL((SELECT SUM((case invoicetype when 4 then 0 - Amount else Amount end)           
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = i.Product_Code      
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
             
 "Purchase Return" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Purchase Return Value (%c)" = ISNULL((SELECT SUM(Quantity           
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, items i    
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID    
 AND AdjustmentReturnDetail.Product_Code = i.Product_Code           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),          
           
 "Adjustments" = cast(ISNULL((SELECT SUM(Quantity - OldQty)           
 FROM StockAdjustment, StockAdjustmentAbstract           
 WHERE ISNULL(AdjustmentType,0) = 1           
 And Product_Code = Items.Product_Code           
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Stock Transfer Out" = cast(IsNull((Select Sum(Quantity)           
 From StockTransferOutAbstract, StockTransferOutDetail          
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial          
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferOutAbstract.Status & 192 = 0          
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Stock Transfer In" = cast(IsNull((Select Sum(Quantity)           
 From StockTransferInAbstract, StockTransferInDetail           
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferInAbstract.Status & 192 = 0          
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial        
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
 And ClaimsNote.Status & 1 <> 0          
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0)  * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),      
       
 "On Hand Qty" = cast((CASE           
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice <> 0))          
 end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "On Hand Free Qty" = cast((CASE          
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))          
 end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "On Hand Damage Qty" = cast((CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))          
 end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
    
 "Total On Hand Qty" = cast((CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Quantity          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code), 0) +          
 (SELECT ISNULL(SUM(Pending), 0)           
 FROM VanStatementDetail, VanStatementAbstract           
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code))          
 end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
           
 "On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract, items i    
 WHERE Items.Product_Code = i.product_code and VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))          
 end,          
           
 "On Hand Damages Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Value, 0)    
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i    
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)          
 end,           
           
 "Total On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value     
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code and items.product_code = openingdetails.product_code    
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract , items i          
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code and i.product_code = Items.Product_Code))          
 end,       
/* "Pending Orders" = IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
 IsNull(dbo.GetSRPending(Items.Product_Code), 0),    */  
"Pending Orders" = ((Select IsNull(Sum(Pending),0) From PODetail, POAbstract    
Where POAbstract.PONumber = PODetail.PONumber And   
dbo.stripdatefromtime(PODate) BETWEEN @FROMDATE AND @TODATE And (POAbstract.Status & 128) = 0    
And PODetail.Product_Code = Items.Product_Code And PODetail.Pending > 0) +   
(Select IsNull(Sum(Pending),0) From Stock_Request_Abstract, Stock_Request_Detail     
Where Product_Code = Items.Product_Code And Pending > 0 And    
Stock_Request_Abstract.Stock_Req_Number = Stock_Request_Detail.Stock_Req_Number    
And Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE  
And (Stock_Request_Abstract.Status & 128) = 0)) * ISNULL(Items.ConversionFactor, 0),  
   
  
       
 "Forum Code" = Items.Alias               
 into #SDPipeline1  
 FROM Items, OpeningDetails, Manufacturer, Brand, ItemCategories, ConversionTable      
 WHERE  Items.Product_Code *= OpeningDetails.Product_Code AND        
  OpeningDetails.Opening_Date = @FROMDATE  And        
 Items.ManufacturerID = Manufacturer.ManufacturerID And        
  Manufacturer.Manufacturer_Name In (Select Manufacturer From #TmpMfr) And      
  Items.BrandID = Brand.BrandID And      
 Items.ConversionUnit *= ConversionTable.ConversionID And     
  Brand.BrandName In (Select Division From #TmpDiv) And Items.CategoryID = ItemCategories.CategoryID      
 set @Query =  N'select [Item Code], [Item Name], [FLevel] as ['+@FirstLevel+'], [LLevel] as ['+@LastLevel+'], [Conversion Factor], [Opening Quantity],  
 [Free Opening Quantity], [Damage Opening Quantity], [Total Opening Quantity], [Opening Value], [Damage Opening Value],   
 [Total Opening Value], [Purchase], [Free Purchase], [Sales Return Saleable], [Sales Return Damages], [Total Issues],  
 [Free Issues], [Sales Value (%c)], [Purchase Value (%c)], [Sales Return Saleable Value (%c)],   
 [Sales Return Damages Value (%c)], [Purchase Return Value (%c)], [Purchase Return], [Adjustments], [Stock Transfer Out],  
 [Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Free Qty], [On Hand Damage Qty], [Total On Hand Qty],   
 [On Hand Value], [On Hand Damages Value], [Total On Hand Value], [Pending Orders], [Forum Code]  
   from #SDPipeline1'  
 exec sp_executesql @Query  
 drop table #SDPipeline1  
end    
    
else --Reporting Unit    
begin    
 SELECT  Items.Product_Code,           
 "FLevel" =  dbo.fn_FirstLevelCategory(items.categoryid),    
 "LLevel" = ItemCategories.Category_Name,      
 "Item Code" = Items.Product_Code,           
 "Item Name" = ProductName,           
 "Reporting UOM" =  UOM.Description,  -- changed                  
 "Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),           
           
 "Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),           
           
 "Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Total Opening Quantity" = cast (ISNULL(Opening_Quantity, 0)  / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
      
 "Opening Value" = case @StockVal     
 when 'PTSS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTS    
 when 'PTS' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*PTR    
 when 'ECP' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*ECP    
 when 'PTR' then (ISNULL(Opening_quantity, 0) - IsNull(Damage_Opening_quantity, 0))*company_price    
 end,    
           
 "Damage Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Damage_Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Damage_Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Damage_Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Damage_Opening_Quantity, 0)*company_price     
 end,    
    
 "Total Opening Value" = case @StockVal     
 when 'PTSS' then IsNull(Opening_Quantity, 0)*PTS    
 when 'PTS' then IsNull(Opening_Quantity, 0)*PTR    
 when 'ECP' then IsNull(Opening_Quantity, 0)*ECP    
 when 'PTR' then IsNull(Opening_Quantity, 0)*company_price     
 end,    
           
 "Purchase" = cast (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Free Purchase" = cast (ISNULL((SELECT SUM(IsNull(FreeQty, 0))           
 FROM GRNAbstract, GRNDetail           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Purchase Value (%c)" = ISNULL((SELECT SUM((QuantityReceived - QuantityRejected)     
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM GRNAbstract, GRNDetail , items i           
 WHERE GRNAbstract.GRNID = GRNDetail.GRNID           
 and items.Product_Code = i.product_code    
 AND GRNDetail.Product_Code = Items.Product_Code           
 AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And           
 (GRNAbstract.GRNStatus & 64) = 0 And          
 (GRNAbstract.GRNStatus & 32) = 0 ), 0) ,          
           
 "Sales Return Saleable" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Sales Return Damages" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Sales Return Saleable Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP 
when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) = 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) ,          
           
 "Sales Return Damages Value (%c)" = ISNULL((SELECT SUM(Quantity    
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceDetail.Product_Code = i.Product_Code)    
 AND (InvoiceAbstract.InvoiceType = 4)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND (InvoiceAbstract.Status & 32) <> 0          
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
           
 "Total Issues" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 2)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6))           
 + cast(ISNULL((SELECT SUM(Quantity)           
 FROM DispatchDetail, DispatchAbstract           
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
 AND Isnull(DispatchAbstract.Status, 0) & 64 = 0        
 AND DispatchDetail.Product_Code = Items.Product_Code           
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Free Issues" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM InvoiceDetail, InvoiceAbstract           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.InvoiceType = 2)           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE          
 And InvoiceDetail.SalePrice = 0), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6))           
 + cast(ISNULL((SELECT SUM(Quantity)           
 FROM DispatchDetail, DispatchAbstract           
 WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
 AND (DispatchAbstract.Status & 64) = 0           
 AND DispatchDetail.Product_Code = Items.Product_Code           
 AND DispatchAbstract.DispatchDate BETWEEN @FROMDATE AND @TODATE          
 And DispatchDetail.SalePrice = 0), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Sales Value (%c)" = ISNULL((SELECT SUM((case invoicetype when 4 then 0 - Amount else Amount end)           
 * case invoicedetail.saleprice when 0 then 0 else isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0)end)    
 FROM InvoiceDetail, InvoiceAbstract, items i           
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
 AND (InvoiceAbstract.Status & 128) = 0           
 AND InvoiceDetail.Product_Code = i.Product_Code           
 AND InvoiceDetail.Product_Code = Items.Product_Code           
 AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE), 0),          
    
   
 "Purchase Return" = cast(ISNULL((SELECT SUM(Quantity)           
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract           
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Purchase Return Value (%c)" = ISNULL((SELECT SUM(Quantity           
 * isnull(Case @StockVal     
  When 'PTSS' Then i.PTS     
  when 'PTS' then i.PTR     
  when 'ECP' then i.ECP     
  when 'PTR' then i.company_price End,0))    
 FROM AdjustmentReturnDetail, AdjustmentReturnAbstract, items i    
 WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID           
 AND AdjustmentReturnDetail.Product_Code = i.Product_Code           
 AND AdjustmentReturnDetail.Product_Code = Items.Product_Code           
 AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE       
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
 And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0),          
           
 "Adjustments" = cast(ISNULL((SELECT SUM(Quantity - OldQty)           
 FROM StockAdjustment, StockAdjustmentAbstract           
 WHERE ISNULL(AdjustmentType,0) = 1           
 And Product_Code = Items.Product_Code           
 AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
 AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Stock Transfer Out" = cast(IsNull((Select Sum(Quantity)           
 From StockTransferOutAbstract, StockTransferOutDetail          
 Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial          
 And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferOutAbstract.Status & 192 = 0          
 And StockTransferOutDetail.Product_Code = Items.Product_Code), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Stock Transfer In" = cast(IsNull((Select Sum(Quantity)           
 From StockTransferInAbstract, StockTransferInDetail           
 Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
 And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate           
 And StockTransferInAbstract.Status & 192 = 0          
 And StockTransferInDetail.Product_Code = Items.Product_Code), 0) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                   
 And ClaimsNote.Status & 1 <> 0          
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0)  / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),      
       
 "On Hand Qty" = cast((CASE           
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice <> 0))          
 end) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "On Hand Free Qty" = cast((CASE           
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
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0))          
 end) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "On Hand Damage Qty" = cast((CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Quantity, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))          
 end) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
    
 "Total On Hand Qty" = cast((CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Quantity          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (ISNULL((SELECT SUM(Quantity)           
 FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code), 0) +          
 (SELECT ISNULL(SUM(Pending), 0)           
 FROM VanStatementDetail, VanStatementAbstract           
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code))          
 end) / ISNULL(Items.ReportingUnit, 0) as Decimal(18,6)),          
           
 "On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)          
 FROM OpeningDetails           
 WHERE OpeningDetails.Product_Code = Items.Product_Code           
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE i.Product_Code = b.Product_Code And b.Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract, items i    
 WHERE Items.Product_Code = i.product_code and VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))          
 end,          
           
 "On Hand Damages Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select IsNull(Damage_Opening_Value, 0)    
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code     
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 (SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i    
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)          
 end,           
           
 "Total On Hand Value" = CASE           
 when (@TODATE < @NEXT_DATE) THEN           
 ISNULL((Select Opening_Value     
 FROM OpeningDetails    
 WHERE OpeningDetails.Product_Code = Items.Product_Code and items.product_code = openingdetails.product_code    
 AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)          
 ELSE           
 ((SELECT ISNULL(SUM(Quantity * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM Batch_Products b, items i          
 WHERE b.Product_Code = i.Product_Code and b.Product_Code = Items.Product_Code) +           
 (SELECT ISNULL(SUM(Pending * case @StockVal when 'PTSS' then i.PTS when 'PTS' then i.PTR when 'ECP' then i.ECP when 'PTR' then i.company_price end), 0)           
 FROM VanStatementDetail, VanStatementAbstract , items i          
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
 AND (VanStatementAbstract.Status & 128) = 0           
 And VanStatementDetail.Product_Code = Items.Product_Code and i.product_code = Items.Product_Code))          
 end,       
/* "Pending Orders" = IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
 IsNull(dbo.GetSRPending(Items.Product_Code), 0),    */  
"Pending Orders" =   
 ((Select isnull(Sum(IsNull(Pending,0)),0) From PODetail, POAbstract    
  Where   
  POAbstract.PONumber = PODetail.PONumber And   
  dbo.stripdatefromtime (PODate) BETWEEN @FROMDATE AND @TODATE And   
  (POAbstract.Status & 128) = 0  And   
  PODetail.Product_Code = Items.Product_Code And   
  PODetail.Pending > 0  
 )   
 + (  
 SELECT ISNULL(SUM(PENDING),0) FROM STOCK_REQUEST_ABSTRACT, STOCK_REQUEST_DETAIL     
 WHERE   
 PRODUCT_CODE = ITEMS.PRODUCT_CODE AND   
 PENDING > 0 AND    
 STOCK_REQUEST_ABSTRACT.STOCK_REQ_NUMBER = STOCK_REQUEST_DETAIL.STOCK_REQ_NUMBER AND   
 STOCK_REQUEST_ABSTRACT.STOCK_REQ_DATE BETWEEN @FROMDATE AND @TODATE  
 AND (STOCK_REQUEST_ABSTRACT.STATUS & 128) = 0))   
/ CAST(CASE ISNULL(ITEMS.REPORTINGUNIT, 0)  
  WHEN 0 THEN     
  1     
  ELSE ISNULL(ITEMS.REPORTINGUNIT, 0) END     
  AS Decimal(18,6)),  
       
 "Forum Code" = Items.Alias      
           
 into #SDPipeline2  
 FROM Items, OpeningDetails, Manufacturer, Brand, ItemCategories, uom    
 WHERE  Items.Product_Code *= OpeningDetails.Product_Code AND        
  OpeningDetails.Opening_Date = @FROMDATE  And        
 Items.ManufacturerID = Manufacturer.ManufacturerID And        
  Manufacturer.Manufacturer_Name In (Select Manufacturer From #TmpMfr) And      
  Items.BrandID = Brand.BrandID And      
 Items.ReportingUOM *= UOM.UOM And     
  Brand.BrandName In (Select Division From #TmpDiv) And Items.CategoryID = ItemCategories.CategoryID      
 set @Query =  N'select [Item Code], [Item Name], [FLevel] as ['+@FirstLevel+'], [LLevel] as ['+@LastLevel+'], [Reporting UOM], [Opening Quantity],  
 [Free Opening Quantity], [Damage Opening Quantity], [Total Opening Quantity], [Opening Value], [Damage Opening Value],   
 [Total Opening Value], [Purchase], [Free Purchase], [Sales Return Saleable], [Sales Return Damages], [Total Issues],  
 [Free Issues], [Sales Value (%c)], [Purchase Value (%c)], [Sales Return Saleable Value (%c)],   
 [Sales Return Damages Value (%c)], [Purchase Return Value (%c)], [Purchase Return], [Adjustments], [Stock Transfer Out],  
 [Stock Transfer In], [Stock Destruction], [On Hand Qty], [On Hand Free Qty], [On Hand Damage Qty], [Total On Hand Qty],   
 [On Hand Value], [On Hand Damages Value], [Total On Hand Value], [Pending Orders], [Forum Code]  
   from #SDPipeline2'  
 exec sp_executesql @Query  
 drop table #SDPipeline2  
end    
end    
  
Drop table #tmpMfr  
Drop table #tmpDiv
