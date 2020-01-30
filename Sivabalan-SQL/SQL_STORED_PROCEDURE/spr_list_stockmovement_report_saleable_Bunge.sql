CREATE procedure [dbo].[spr_list_stockmovement_report_saleable_Bunge]  (@Mfr NVarchar(2550),            
              @Division NVarchar(2550),    
              @UOM NVarChar(255),    
              @FROMDATE datetime,    
              @TODATE datetime,    
              @ItemCode NVarChar(2550))    
As            
        
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)          
Create table #tmpMfr(Manufacturer NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpDiv(Division NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
create table #tmpProd(product_code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
Create Table #Products(Product_Code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS Primary Key,  
ProductName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
UOM int,   
ReportingUOM int,   
ReportingUnit Decimal(18, 6),   
ConversionUnit Int,   
ConversionFactor Decimal(18, 6),  
CategoryID Int,   
Alias NVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,   
SalesReturnSaleable Decimal(18, 6) Default (0),   
SalesReturnDamages Decimal(18, 6) Default (0),   
SaleableIssues Decimal(18, 6) Default (0),   
FreeIssues Decimal(18, 6) Default (0),   
SalesValue Decimal(18, 6) Default (0))  
    
if @Mfr = '%'           
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer          
Else          
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)          
          
if @Division = '%'          
   Insert into #tmpDiv select BrandName from Brand          
Else          
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@Division,@Delimeter)          
    
if @ItemCode = '%'    
 Insert InTo #tmpProd Select Product_code From Items    
Else    
 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)    
  
--Filter Item details from item master        
Insert Into #Products (Product_Code, ProductName, UOM, ReportingUOM, ReportingUnit, ConversionUnit,  
ConversionFactor, CategoryID, Alias)   
Select Product_Code, ProductName, UOM, ReportingUOM, ReportingUnit, ConversionUnit,  
ConversionFactor, CategoryID, Alias  
From Items, Manufacturer, Brand  
Where   
Items.ManufacturerID = Manufacturer.ManufacturerID And          
Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr) And        
Items.BrandID = Brand.BrandID And        
Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv) And     
Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)          
  
--Filter valid invoices for the given dates  
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
  
declare @NEXT_DATE datetime            
DECLARE @CORRECTED_DATE datetime            
  
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS NVarchar) + N'/'             
+ CAST(DATEPART(mm, @TODATE) as NVarchar) + N'/'             
+ cast(DATEPART(yyyy, @TODATE) AS NVarchar)            
  
-- SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS NVarchar) + N'/'             
-- + CAST(DATEPART(mm, GETDATE()) as NVarchar) + N'/'             
-- + cast(DATEPART(yyyy, GETDATE()) AS NVarchar)    

SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/'                   
+ CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/'                   
+ cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)                  
       
        
SELECT  #Products.Product_Code,             
"Item Code" = #Products.Product_Code,             
"Item Name" = ProductName,             
"Category Name" = ItemCategories.Category_Name,    
"UOM Description" =     
Case @UOM   
When 'Sales UOM' Then IsNull((Select [Description] From UOM Where UOM = #Products.UOM), '')    
When 'Reporting UOM' Then IsNull((Select [Description] From UOM Where UOM = #Products.ReportingUOM), '')    
When 'Conversion Factor' Then IsNull((Select [ConversionUnit] From ConversionTable Where ConversionID = #Products.ConversionUnit), '')    
End,     
            
"Opening Quantity" =     
Cast(Case @UOM   
When 'Sales UOM' Then   
 (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0))    
When 'Reporting UOM' Then   
 dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)))    
When 'Conversion Factor' Then   
 (ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) *     
 (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
End As Decimal(18,6)),  
  
"Free Opening Quantity" =     
Cast(Case @UOM   
When 'Sales UOM' Then   
 (ISNULL(Free_Saleable_Quantity, 0))    
When 'Reporting UOM' Then     
 dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL(Free_Saleable_Quantity, 0)))    
When 'Conversion Factor' Then (ISNULL(Free_Saleable_Quantity, 0)) *    
 (Case IsNull(#Products.ConversionFactor, 0)   
 When 0 Then 1 Else #Products.ConversionFactor End)    
End As Decimal(18,6)),             
            
"Damage Opening Quantity" =     
Cast(Case @UOM   
When 'Sales UOM' Then   
 (ISNULL(Damage_Opening_Quantity, 0))    
When 'Reporting UOM' Then     
 dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL(Damage_Opening_Quantity, 0)))    
When 'Conversion Factor' Then   
 (ISNULL(Damage_Opening_Quantity, 0)) *     
 (Case IsNull(#Products.ConversionFactor, 0)   
 When 0 Then 1 Else #Products.ConversionFactor End)    
End As Decimal(18,6)),            
            
"Total Opening Quantity" =     
Cast(Case @UOM   
When 'Sales UOM' Then   
 (ISNULL(Opening_Quantity, 0))    
When 'Reporting UOM' Then     
 dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL(Opening_Quantity, 0)))    
When 'Conversion Factor' Then   
 (ISNULL(Opening_Quantity, 0)) *     
 (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
End As Decimal(18,6)),            
            
"Opening Value" = ISNULL(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),            
            
"Damage Opening Value" = IsNull(Damage_Opening_Value, 0),     
    
"Total Opening Value" = ISNULL(Opening_Value, 0),  
  
"Purchase" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)             
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0))    
 When 'Reporting UOM' Then      
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)    
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)))    
 When 'Conversion Factor' Then (ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)             
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),  
            
"Free Purchase" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))             
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0))    
    When 'Reporting UOM' Then       
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((SELECT SUM(IsNull(FreeQty, 0))    
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)))    
 When 'Conversion Factor' Then (ISNULL((SELECT SUM(IsNull(FreeQty, 0))             
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID             
  AND GRNDetail.Product_Code = #Products.Product_Code             
  AND GRNAbstract.GRNDate BETWEEN @FROMDATE AND @TODATE And             
  (GRNAbstract.GRNStatus & 64) = 0 And            
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),  
  
"Sales Return Saleable" =  
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  SalesReturnSaleable  
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, SalesReturnSaleable)  
 When 'Conversion Factor' Then   
  SalesReturnSaleable *  
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),  
            
"Sales Return Damages" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  SalesReturnDamages  
 When 'Reporting UOM' Then    
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, SalesReturnDamages)  
 When 'Conversion Factor' Then   
  SalesReturnDamages *  
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)  
 End As Decimal(18,6)),  
  
"Total Issues" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  SaleableIssues + FreeIssues  
 When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, SaleableIssues + FreeIssues)  
 When 'Conversion Factor' Then   
  (SaleableIssues + FreeIssues) *  
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),    
        
"Saleable Issues" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  SaleableIssues  
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, SaleableIssues)  
 When 'Conversion Factor' Then   
  SaleableIssues *   
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),    
            
"Free Issues" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  FreeIssues  
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, FreeIssues)  
 When 'Conversion Factor' Then   
  FreeIssues *  
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),  
  
"Sales Value" = SalesValue,  
  
"Purchase Return" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (ISNULL((SELECT SUM(Quantity)             
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract             
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID    
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code             
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE         
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0        
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0))    
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code,(ISNULL((SELECT  SUM(Quantity)    
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract             
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID    
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code             
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE         
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0        
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)))    
 When 'Conversion Factor' Then   
  (ISNULL((SELECT SUM(Quantity)             
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract             
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID    
  AND AdjustmentReturnDetail.Product_Code = #Products.Product_Code             
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FROMDATE AND @TODATE         
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0        
  And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)  
 End As Decimal(18,6)),  
            
"Adjustments" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (ISNULL((SELECT SUM(Quantity - OldQty)             
  FROM StockAdjustment, StockAdjustmentAbstract             
  WHERE ISNULL(AdjustmentType,0) in (1, 3)             
  And Product_Code = #Products.Product_Code             
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID            
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0))    
 When 'Reporting UOM' Then      
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((SELECT  SUM(Quantity - OldQty)    
  FROM StockAdjustment, StockAdjustmentAbstract             
  WHERE ISNULL(AdjustmentType,0) in (1, 3)             
  And Product_Code = #Products.Product_Code             
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID            
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)))    
 When 'Conversion Factor' Then   
  (ISNULL((SELECT SUM(Quantity - OldQty)             
  FROM StockAdjustment, StockAdjustmentAbstract             
  WHERE ISNULL(AdjustmentType,0) in (1, 3)             
  And Product_Code = #Products.Product_Code             
  AND StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID            
  AND AdjustmentDate BETWEEN @FROMDATE AND @TODATE), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),  
      
"Stock Transfer Out" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (IsNull((Select Sum(Quantity)             
  From StockTransferOutAbstract, StockTransferOutDetail            
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial            
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferOutAbstract.Status & 192 = 0            
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0))    
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (IsNull((Select Sum(Quantity)             
  From StockTransferOutAbstract, StockTransferOutDetail            
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial            
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferOutAbstract.Status & 192 = 0            
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)))    
 When 'Conversion Factor' Then   
  (IsNull((Select Sum(Quantity)             
  From StockTransferOutAbstract, StockTransferOutDetail            
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial            
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferOutAbstract.Status & 192 = 0            
  And StockTransferOutDetail.Product_Code = #Products.Product_Code), 0)) *  
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),    
            
"Stock Transfer In" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (IsNull((Select Sum(Quantity)             
  From StockTransferInAbstract, StockTransferInDetail             
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial            
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferInAbstract.Status & 192 = 0            
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0))     
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (IsNull((Select  Sum(Quantity)    
  From StockTransferInAbstract, StockTransferInDetail             
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial            
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferInAbstract.Status & 192 = 0            
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)))    
 When 'Conversion Factor' Then   
  (IsNull((Select Sum(Quantity)             
  From StockTransferInAbstract, StockTransferInDetail             
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial            
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate             
  And StockTransferInAbstract.Status & 192 = 0           
  And StockTransferInDetail.Product_Code = #Products.Product_Code), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)                            
 End As Decimal(18,6)),  
    
"Stock Destruction" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
  And ClaimsNote.Status & 1 <> 0            
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6)))    
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)    
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
  And ClaimsNote.Status & 1 <> 0            
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))))    
 When 'Conversion Factor' Then   
  (cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
  And ClaimsNote.Status & 1 <> 0            
  And StockDestructionDetail.Product_Code = #Products.Product_Code), 0) as Decimal(18,6))) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),    
        
"On Hand Qty" =   
 Cast(  
 CASE when (@TODATE < @NEXT_DATE) THEN             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)    
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails    
   WHERE OpeningDetails.Product_Code = #Products.Product_Code     
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))    
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)    
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails    
   WHERE OpeningDetails.Product_Code = #Products.Product_Code     
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))    
  When 'Conversion Factor' Then   
   (ISNULL((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)    
   - IsNull(Damage_Opening_Quantity, 0) FROM OpeningDetails    
   WHERE OpeningDetails.Product_Code = #Products.Product_Code     
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 ELSE             
  Case @UOM   
  When 'Sales UOM' Then   
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
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, ((ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And     
   IsNull(Damage, 0) = 0), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code And     
   VanStatementDetail.PurchasePrice <> 0))))     
  When 'Conversion Factor' Then       
   ((ISNULL((SELECT  SUM(Quantity)    
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And     
   IsNull(Damage, 0) = 0), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code And     
   VanStatementDetail.PurchasePrice <> 0))) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 End As Decimal(18,6)),            
            
"On Hand Free Qty" =     
 Cast(  
 CASE when (@TODATE < @NEXT_DATE) THEN             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))    
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))    
  When 'Conversion Factor' Then   
   (ISNULL((Select IsNull(Free_Saleable_Quantity, 0)            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 ELSE           
  Case @UOM   
  When 'Sales UOM' Then   
   ((ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +      
   (SELECT ISNULL(SUM(Pending), 0)         
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0     
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0)))    
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, ((ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +      
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))))    
  When 'Conversion Factor' Then   
   ((ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +      
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.PurchasePrice = 0))) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 End As Decimal(18,6)),            
     
"On Hand Damage Qty" =   
 Cast(CASE When (@TODATE < @NEXT_DATE) THEN             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)            
   FROM OpeningDetails     
   WHERE OpeningDetails.Product_Code = #Products.Product_Code      
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))    
  When 'Reporting UOM' Then       
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)            
   FROM OpeningDetails     
   WHERE OpeningDetails.Product_Code = #Products.Product_Code      
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))    
  When 'Conversion Factor' Then   
   (ISNULL((Select IsNull(Damage_Opening_Quantity, 0)            
   FROM OpeningDetails     
   WHERE OpeningDetails.Product_Code = #Products.Product_Code      
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 ELSE             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((SELECT SUM(Quantity)     
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0))    
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((SELECT SUM(Quantity)     
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)) )    
  When 'Conversion Factor' Then   
   (ISNULL((SELECT SUM(Quantity)     
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0), 0)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 End As Decimal(18,6)),            
            
"Total On Hand Qty" =   
 Cast(CASE   
 When (@TODATE < @NEXT_DATE) THEN             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((Select Opening_Quantity            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))    
  When 'Reporting UOM' Then      
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((Select Opening_Quantity            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)))     
  When 'Conversion Factor' Then   
   (ISNULL((Select Opening_Quantity            
   FROM OpeningDetails             
   WHERE OpeningDetails.Product_Code = #Products.Product_Code             
   AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 ELSE             
  Case @UOM   
  When 'Sales UOM' Then   
   (ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code))    
  When 'Reporting UOM' Then     
   dbo.sp_Get_ReportingUOMQty(#Products.Product_Code, (ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code)))    
  When 'Conversion Factor' Then   
   (ISNULL((SELECT SUM(Quantity)             
   FROM Batch_Products             
   WHERE Product_Code = #Products.Product_Code), 0) +            
   (SELECT ISNULL(SUM(Pending), 0)             
   FROM VanStatementDetail, VanStatementAbstract             
   WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
   AND (VanStatementAbstract.Status & 128) = 0             
   And VanStatementDetail.Product_Code = #Products.Product_Code)) *     
   (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
  End    
 End As Decimal(18,6)),            
            
"On Hand Value" =   
 CASE   
 when (@TODATE < @NEXT_DATE) THEN             
  ISNULL((Select Opening_Value - IsNull(Damage_Opening_Value, 0)            
  FROM OpeningDetails             
  WHERE OpeningDetails.Product_Code = #Products.Product_Code             
  AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)            
 ELSE             
  ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)             
  FROM Batch_Products             
  WHERE Product_Code = #Products.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +             
  (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)             
  FROM VanStatementDetail, VanStatementAbstract             
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
  AND (VanStatementAbstract.Status & 128) = 0             
  And VanStatementDetail.Product_Code = #Products.Product_Code And VanStatementDetail.SalePrice <> 0))            
 end,            
            
"On Hand Damages Value" =   
 CASE             
 when (@TODATE < @NEXT_DATE) THEN             
  ISNULL((Select IsNull(Damage_Opening_Value, 0)            
  FROM OpeningDetails             
  WHERE OpeningDetails.Product_Code = #Products.Product_Code             
  AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)            
 ELSE             
  (SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)             
  FROM Batch_Products             
  WHERE Product_Code = #Products.Product_Code And IsNull(Damage, 0) > 0)            
 end,             
            
"Total On Hand Value" =   
 CASE             
 when (@TODATE < @NEXT_DATE) THEN             
  ISNULL((Select Opening_Value            
  FROM OpeningDetails             
  WHERE OpeningDetails.Product_Code = #Products.Product_Code             
  AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)            
 ELSE             
  ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)             
  FROM Batch_Products             
  WHERE Product_Code = #Products.Product_Code) +             
  (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)             
  FROM VanStatementDetail, VanStatementAbstract             
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial             
  AND (VanStatementAbstract.Status & 128) = 0             
  And VanStatementDetail.Product_Code = #Products.Product_Code))            
 end,         
  
"Pending Orders" =     
 Cast(Case @UOM   
 When 'Sales UOM' Then   
  (IsNull(dbo.GetPOPending (#Products.Product_Code), 0) +         
  IsNull(dbo.GetSRPending(#Products.Product_Code), 0))        
 When 'Reporting UOM' Then     
  dbo.sp_Get_ReportingUOMQty(#Products.Product_Code,     
  (IsNull(dbo.GetPOPending (#Products.Product_Code), 0) +         
  IsNull(dbo.GetSRPending(#Products.Product_Code), 0)))    
 When 'Conversion Factor' Then   
  (IsNull(dbo.GetPOPending (#Products.Product_Code), 0) +         
  IsNull(dbo.GetSRPending(#Products.Product_Code), 0)) *     
  (Case IsNull(#Products.ConversionFactor, 0) When 0 Then 1 Else #Products.ConversionFactor End)    
 End As Decimal(18,6)),    
  
"Forum Code" = #Products.Alias        
  
FROM #Products, OpeningDetails, UOM, ItemCategories   
WHERE   #Products.Product_Code *= OpeningDetails.Product_Code AND          
OpeningDetails.Opening_Date = @FROMDATE          
AND #Products.UOM *= UOM.UOM And          
#Products.CategoryID = ItemCategories.CategoryID  
  
Drop Table #Dispatch  
Drop Table #Invoice  
Drop Table #Products       
Drop table #tmpMfr        
Drop table #tmpDiv        
  
-- 
-- spr_list_manufacturerwise_stockmovement
-- 
-- select * from OpeningDetails
