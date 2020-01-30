CREATE procedure [dbo].[spr_list_Itemwise_Companywise_Stock_Movement_Chevorn]             
(            
 @Manufacturer NVarChar(4000),            
 @ItemCode NVarChar(4000),   
 @FromDate DateTime,            
 @ToDate DateTime            
)                    
as                    
    
Declare @Delimeter as Char(1)                
Set @Delimeter=Char(15)                   
       
              
CREATE Table #TmpProd(Product_Code NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)                  
If @ItemCode = '%'                    
 Insert InTo #TmpProd Select Product_Code From Items                    
Else                    
 Insert InTo #TmpProd Select * From dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)              
            
Create table #TmpMfr(Manufacturer NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                
If @Manufacturer='%'                       
 Insert into #TmpMfr select Manufacturer_Name From Manufacturer                      
Else                      
 Insert into #TmpMfr select * From dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)                      
              
Create Table #Temp            
(            
 Itemcode1 NVarChar(255), ItemCode NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,              
 ItemName NVarChar(255),CategoryName  NVarChar(255),OpeningQuantity Decimal(18,6),              
 FreeOpeningQuantity Decimal(18,6),DamageOpeningQuantity Decimal(18,6),              
 TotalOpeningValue  Decimal(18,6),OpeningValue Decimal(18,6),DamageOpeningValue Decimal(18,6),              
 TotalOpeningValue1  Decimal(18,6),Purchase Decimal(18,6),FreePurchase Decimal(18,6),              
 SalesReturnSaleable Decimal(18,6),SaleReturnDamages Decimal(18,6),TotalIssues Decimal(18,6),              
 SalableIssues Decimal(18,6),FreeIssues Decimal(18,6),SalesValue Decimal(18,6),              
 PurchasReturn Decimal(18,6),Adjustments  Decimal(18,6),StockTransferOut Decimal(18,6),              
 StockTransferIn Decimal(18,6),StockDestruction Decimal(18,6),OnHandQty Decimal(18,6),              
 OnHandFreeQty  Decimal(18,6),OnHandDamageQty Decimal(18,6),TotalOnHandQty Decimal(18,6),              
 OnHandValue Decimal(18,6),OnHandDamagesValue  Decimal(18,6),TotalOnHandValue Decimal(18,6),              
 PendingOrders Decimal(18,6)              
)               
            
Insert into #Temp            
(            
 Itemcode1,ItemCode,ItemName,CategoryName,OpeningQuantity,FreeOpeningQuantity,DamageOpeningQuantity,              
 TotalOpeningValue,OpeningValue,DamageOpeningValue,TotalOpeningValue1,Purchase,FreePurchase,              
 SalesReturnSaleable,SaleReturnDamages,TotalIssues,SalableIssues,FreeIssues,SalesValue,              
 PurchasReturn,Adjustments,StockTransferOut,StockTransferIn,StockDestruction,OnHandQty,              
 OnHandFreeQty,OnHandDamageQty,TotalOnHandQty,OnHandValue,OnHandDamagesValue,TotalOnHandValue,              
 PendingOrders              
)              
Select             
 ReportAbstractReceived.Field1+';'+ CAST(Manufacturer.ManufacturerID AS NVARCHAR),                
 "Item Code" = ReportAbstractReceived.Field1,                
 "Item Name" = ReportAbstractReceived.Field2,                    
 "Category Name" =             
  Case             
   When ((Min(ReportAbstractReceived.Field3)) <> (Max(ReportAbstractReceived.Field3))) Then 'CATEGORY MISMATCH'                
   Else Max(ReportAbstractReceived.Field3)                
  End,                
 "Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field5 as Decimal(18,6))),                  
 "Free Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field6 as Decimal(18,6))),                  
 "Damage Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field7 as Decimal(18,6))),                  
 "Total Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field8 as  Decimal(18,6))),                  
 "Opening Value" = Sum(Cast(ReportAbstractReceived.Field9 as Decimal(18,6))),                  
 "Damage Opening Value" = Sum(Cast(ReportAbstractReceived.Field10 as Decimal(18,6))),                  
 "Total Opening Value" = Sum(Cast(ReportAbstractReceived.Field11 as Decimal(18,6))),      
 "Purchase" = Sum(Cast(ReportAbstractReceived.Field12 as Decimal(18,6))),                  
 "Free Purchase" = Sum(Cast(ReportAbstractReceived.Field13 as Decimal(18,6))),            
 "Sales Return Saleable" = Sum(Cast(ReportAbstractReceived.Field14 as Decimal(18,6))),                  
 "Sales Return Damages" = Sum(Cast(ReportAbstractReceived.Field15 as Decimal(18,6))),                  
 "Total Issues" = Sum(Cast(ReportAbstractReceived.Field16 as Decimal(18,6))),              
 "Salable Issues" = Sum(Cast(ReportAbstractReceived.Field17 as Decimal(18,6))),                   
 "Free Issues" = Sum(Cast(ReportAbstractReceived.Field18 as Decimal(18,6))),                  
 "Sales Value " = Sum(Cast(ReportAbstractReceived.Field19 as Decimal(18,6))),                  
 "Purchase Return" = Sum(Cast(ReportAbstractReceived.Field20 as Decimal(18,6))),                  
 "Adjustments" = Sum(Cast(ReportAbstractReceived.Field21 as Decimal(18,6))),                  
 "Stock Transfer Out" = Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))),                  
 "Stock Transfer In" = Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))),                  
 "Stock Destruction" = Sum(Cast(ReportAbstractReceived.Field24 as Decimal(18,6))),              
 "On Hand Qty" = Sum(Cast(ReportAbstractReceived.Field25 as Decimal(18,6))),                  
 "On Hand Free Qty" = Sum(Cast(ReportAbstractReceived.Field26 as Decimal(18,6))),                  
 "On Hand Damage Qty" = Sum(Cast(ReportAbstractReceived.Field27 as Decimal(18,6))),                  
 "Total On Hand Qty" = Sum(Cast(ReportAbstractReceived.Field28 as Decimal(18,6))),                  
 "On Hand Value" = Sum(Cast(ReportAbstractReceived.Field29 as Decimal(18,6))),                  
 "On Hand Damages Value" = Sum(Cast(ReportAbstractReceived.Field30 as Decimal(18,6))),                  
 "Total On Hand Value" = Sum(Cast(ReportAbstractReceived.Field31 as Decimal(18,6))),              
 "Pending Orders" = Sum(Cast(ReportAbstractReceived.Field32 as Decimal(18,6)))                         
From             
 Reports, ReportAbstractReceived,Items,Manufacturer                     
Where             
 Reports.ReportID in (Select ReportID From Reports Where ReportName = 'Stock Movement - Item'                 
   And ParameterID in (Select ParameterID From dbo.GetReportParameters2('Stock Movement - Item')                 
   Where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))                
   And ReportAbstractReceived.Field1 in (Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpProd))                
 And ReportAbstractReceived.ReportID = Reports.ReportID                    
 And Field1 <> N'Item Code'             
 And Field1 <> N'SubTotal:'             
 And Field1 <> N'GrAndTotal:'             
 And Items.ManufacturerID = Manufacturer.ManufacturerID             
 And Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)             
 And Field1=Items.Product_Code              
            
Group By             
 ReportAbstractReceived.Field1,ReportAbstractReceived.Field2,Manufacturer.ManufacturerID                
              
Create Table #Temp1            
(            
 ItemCode1 NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,ItemCode NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,              
 ItemName NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryName  NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,OpeningQuantity Decimal(18,6),              
 FreeOpeningQuantity Decimal(18,6),DamageOpeningQuantity Decimal(18,6),              
 TotalOpeningValue  Decimal(18,6),OpeningValue Decimal(18,6),              
 DamageOpeningValue Decimal(18,6),TotalOpeningValue1  Decimal(18,6),              
 Purchase Decimal(18,6),FreePurchase Decimal(18,6),SalesReturnSaleable Decimal(18,6),            
 SaleReturnDamages Decimal(18,6),TotalIssues Decimal(18,6),SalableIssues Decimal(18,6),              
 FreeIssues Decimal(18,6),SalesValue Decimal(18,6),PurchasReturn Decimal(18,6),              
 Adjustments  Decimal(18,6),StockTransferOut Decimal(18,6),StockTransferIn Decimal(18,6),              
 StockDestruction Decimal(18,6),OnHandQty Decimal(18,6),OnHandFreeQty  Decimal(18,6),              
 OnHandDamageQty Decimal(18,6),TotalOnHandQty Decimal(18,6),OnHandValue Decimal(18,6),              
 OnHandDamagesValue  Decimal(18,6),TotalOnHandValue Decimal(18,6),PendingOrders Decimal(18,6)         
)               
              
Declare @NEXT_DATE DateTime                        
Declare @CORRECTED_DATE DateTime                        
SET @CORRECTED_DATE = Cast(DATEPART(dd, @TODATE) AS NVarChar) + '/'+ Cast(DATEPART(mm, @TODATE) as NVarChar) + '/' + Cast(DATEPART(yyyy, @TODATE) AS NVarChar)                        
    
SET  @NEXT_DATE = Cast(DATEPART(dd, GETDATE()) AS NVarChar) + '/' + Cast(DATEPART(mm, GETDATE()) as NVarChar) + '/' + Cast(DATEPART(yyyy, GETDATE()) AS NVarChar)                        
              
Insert into #Temp1            
(            
 Itemcode1,ItemCode,ItemName,CategoryName,OpeningQuantity,FreeOpeningQuantity,DamageOpeningQuantity,              
 TotalOpeningValue,OpeningValue,DamageOpeningValue,TotalOpeningValue1,Purchase,FreePurchase,              
 SalesReturnSaleable,SaleReturnDamages,TotalIssues,SalableIssues,FreeIssues,SalesValue,              
 PurchasReturn,Adjustments,StockTransferOut,StockTransferIn,StockDestruction,OnHandQty,              
 OnHandFreeQty,OnHandDamageQty,TotalOnHandQty,OnHandValue,OnHandDamagesValue,TotalOnHandValue,              
 PendingOrders              
)              
              
Select * From #Temp              
              
Union All              
              
SELECT              
 ItemCode1 =   Items.Product_Code + ';' + CAST(Manufacturer.ManufacturerID AS NVARCHAR),                   
 "Item Code" = Items.Product_Code,              
 "Item Name" = ProductName,                         
 "Category Name" = ItemCategories.Category_Name,                 
 "Opening Quantity" =(IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)),                  
 "Free Opening Quantity" =  (IsNull(Free_Saleable_Quantity, 0)),                 
 "Damage Opening Quantity" =(IsNull(Damage_Opening_Quantity, 0)),                 
 "Total Opening Quantity" =(IsNull(Opening_Quantity, 0)),                          
 "Opening Value (%c)" = IsNull(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),                          
 "Damage Opening Value (%c)" = IsNull(Damage_Opening_Value, 0),                   
 "Total Opening Value (%c)" = IsNull(Opening_Value, 0),                  
 "Purchase" =              
  (IsNull((Select SUM(QuantityReceived - QuantityRejected)                           
  From GRNAbstract, GRNDetail                           
  Where GRNAbstract.GRNID = GRNDetail.GRNID                           
  And GRNDetail.Product_Code = Items.Product_Code                           
  And GRNAbstract.GRNDate BETWEEN @FromDATE And @TODATE And                           
  (GRNAbstract.GRNStatus & 64) = 0 And                          
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)),                          
 "Free Purchase" =              
  (IsNull((Select SUM(IsNull(FreeQty, 0))                           
  From GRNAbstract, GRNDetail                           
  Where GRNAbstract.GRNID = GRNDetail.GRNID                           
  And GRNDetail.Product_Code = Items.Product_Code                           
  And DBO.STRIPDATEFROMTIME(GRNAbstract.GRNDate) BETWEEN @FromDATE And @TODATE And                           
  (GRNAbstract.GRNStatus & 64) = 0 And                        
  (GRNAbstract.GRNStatus & 32) = 0 ), 0)),                  
 "Sales Return Saleable" =                   
  (IsNull((Select SUM(Quantity) From                   
  InvoiceDetail, InvoiceAbstract              
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 4)                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And (InvoiceAbstract.Status & 32) = 0                          
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0) +                   
  IsNull((Select SUM(Quantity) From                   
InvoiceDetail, InvoiceAbstract                           
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 5)                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0)),                     
 "Sales Return Damages" =                   
  (IsNull((Select SUM(Quantity) From                   
  InvoiceDetail, InvoiceAbstract                   
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 4)                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And (InvoiceAbstract.Status & 32) <> 0                          
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0) +                   
  IsNull((Select SUM(Quantity) From                   
  InvoiceDetail, InvoiceAbstract                   
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 6)                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0)),                   
 "Total Issues" =            
  (IsNull((Select SUM(Quantity) From InvoiceDetail, InvoiceAbstract                   
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 2) And                   
  (InvoiceAbstract.Status & 128) = 0 And                   
  InvoiceDetail.Product_Code = Items.Product_Code                          
  And InvoiceAbstract.InvoiceDate Between @FromDATE And  @TODATE), 0)                           
  + IsNull((Select SUM(Quantity)                           
  From DispatchDetail, DispatchAbstract                           
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                            
  And IsNull(DispatchAbstract.Status, 0) & 64 = 0                        
  And DispatchDetail.Product_Code = Items.Product_Code                           
  And DispatchAbstract.DispatchDate Between @FromDATE And  @TODATE), 0)),                  
 "Saleable Issues" =              
  (IsNull((Select SUM(Quantity) From InvoiceDetail, InvoiceAbstract                  
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 2)                           
  And (InvoiceAbstract.Status & 128) = 0                          
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And InvoiceDetail.SalePrice > 0                       
  And (InvoiceAbstract.Status & 32) = 0                          
  And InvoiceAbstract.InvoiceDate bETWEEN @FromDATE And @TODATE), 0)                      
  + IsNull((Select SUM(Quantity)                           
  From DispatchDetail, DispatchAbstract                           
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                           
  And (DispatchAbstract.Status & 64) = 0                           
  And DispatchDetail.Product_Code = Items.Product_Code          
  And DispatchAbstract.DispatchDate bETWEEN  @FromDATE And @TODATE                          
  And DispatchDetail.SalePrice > 0), 0)),                  
 "Free Issues" =            
  (IsNull((Select SUM(Quantity) From InvoiceDetail, InvoiceAbstract                  
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.InvoiceType = 2)                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE                          
  And InvoiceDetail.SalePrice = 0), 0)                           
  + IsNull((Select SUM(Quantity)                           
  From DispatchDetail, DispatchAbstract                           
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                           
  And (DispatchAbstract.Status & 64) = 0                           
  And DispatchDetail.Product_Code = Items.Product_Code                           
  And DispatchAbstract.DispatchDate BETWEEN @FromDATE And @TODATE                          
  And DispatchDetail.SalePrice = 0), 0)),                  
 "Sales Value (%c)" =             
  IsNull((Select SUM(Case invoicetype When 4 then 0 - Amount Else Amount End)                           
  From InvoiceDetail, InvoiceAbstract                           
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
  And (InvoiceAbstract.Status & 128) = 0                           
  And InvoiceDetail.Product_Code = Items.Product_Code                           
  And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0),                          
 "Purchase Return" =            
  (IsNull((Select SUM(Quantity)                           
  From AdjustmentReturnDetail, AdjustmentReturnAbstract                           
  Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                  
  And AdjustmentReturnDetail.Product_Code = Items.Product_Code                           
  And AdjustmentReturnAbstract.AdjustmentDate BETWEEN @FromDATE And @TODATE                       
  And (IsNull(AdjustmentReturnAbstract.Status, 0) & 64) = 0                      
  And (IsNull(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)),                  
 "Adjustments" =            
  (IsNull((Select SUM(Quantity - OldQty)                           
  From StockAdjustment, StockAdjustmentAbstract                           
  Where IsNull(AdjustmentType,0) in (1, 3)                           
  And Product_Code = Items.Product_Code                           
  And StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                          
  And AdjustmentDate BETWEEN @FromDATE And @TODATE), 0)),                  
 "Stock Transfer Out" =            
  (IsNull((Select Sum(Quantity)                           
  From StockTransferOutAbstract, StockTransferOutDetail                          
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                          
  And StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate                           
  And StockTransferOutAbstract.Status & 192 = 0                          
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)),                  
 "Stock Transfer In" =            
  (IsNull((Select Sum(Quantity)                 
  From StockTransferInAbstract, StockTransferInDetail                           
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                          
  And StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate                           
  And StockTransferInAbstract.Status & 192 = 0                          
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)),                  
 "Stock Destruction" =            
  (Cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                                   
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote                       
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                                  
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID                      
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                                   
  And ClaimsNote.Status & 1 <> 0                          
  And StockDestructionDetail.Product_Code = Items.Product_Code), 0) As Decimal(18,6))),                  
 "On Hand Qty" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
   (IsNull((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)                  
   - IsNull(Damage_Opening_Quantity, 0) From OpeningDetails                  
   Where OpeningDetails.Product_Code = Items.Product_Code                   
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))                  
  Else                           
   ((IsNull((Select SUM(Quantity)                           
   From Batch_Products                           
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And                   
   IsNull(Damage, 0) = 0), 0) +                          
   (Select IsNull(SUM(Pending), 0)                           
   From VanStatementDetail, VanStatementAbstract                           
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial              
   And (VanStatementAbstract.Status & 128) = 0                           
   And VanStatementDetail.Product_Code = Items.Product_Code And                   
   VanStatementDetail.PurchasePrice <> 0)))                
  End,                
 "On Hand Free Qty" =                   
  Case When (@TODATE < @NEXT_DATE) THEN                           
   (IsNull((Select IsNull(Free_Saleable_Quantity, 0)                          
   From OpeningDetails                           
   Where OpeningDetails.Product_Code = Items.Product_Code                           
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))                  
  Else                         
   ((IsNull((Select SUM(Quantity)                           
   From Batch_Products                           
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                    
   (Select IsNull(SUM(Pending), 0)                       
   From VanStatementDetail, VanStatementAbstract                           
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                           
   And (VanStatementAbstract.Status & 128) = 0                           
   And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0)))        End,                  
 "On Hand Damage Qty" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
   (IsNull((Select IsNull(Damage_Opening_Quantity, 0)                          
   From OpeningDetails                   
   Where OpeningDetails.Product_Code = Items.Product_Code                    
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))                
  Else                           
   (IsNull((Select SUM(Quantity)                   
   From Batch_Products        
   Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))                
  End,                                       
 "Total On Hand Qty" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
   (IsNull((Select Opening_Quantity                          
   From OpeningDetails                           
   Where OpeningDetails.Product_Code = Items.Product_Code                           
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0))                  
  Else                           
   (IsNull((Select SUM(Quantity)                           
   From Batch_Products                           
   Where Product_Code = Items.Product_Code), 0) +                          
   (Select IsNull(SUM(Pending), 0)                           
   From VanStatementDetail, VanStatementAbstract                           
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                           
   And (VanStatementAbstract.Status & 128) = 0                           
   And VanStatementDetail.Product_Code = Items.Product_Code))                
  End,                                       
 "On Hand Value (%c)" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
   IsNull((Select Opening_Value - IsNull(Damage_Opening_Value, 0)                          
   From OpeningDetails                           
   Where OpeningDetails.Product_Code = Items.Product_Code                           
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                          
  Else                           
   ((Select IsNull(SUM(Quantity * PurchasePrice), 0)                          
   From Batch_Products                           
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +                           
   (Select IsNull(SUM(Pending * PurchasePrice), 0)                         
   From VanStatementDetail, VanStatementAbstract                           
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                           
   And (VanStatementAbstract.Status & 128) = 0                           
   And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))    
   End,     
 "On Hand Damages Value (%c)" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
   IsNull((Select IsNull(Damage_Opening_Value, 0)                          
   From OpeningDetails Where OpeningDetails.Product_Code = Items.Product_Code                           
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                          
  Else                           
   (Select IsNull(SUM(Quantity * PurchasePrice), 0)                          
   From Batch_Products                           
   Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)    
  End,                           
 "Total On Hand Value" =             
  Case When (@TODATE < @NEXT_DATE) THEN                           
  IsNull((Select Opening_Value                          
   From OpeningDetails                           
   Where OpeningDetails.Product_Code = Items.Product_Code                           
   And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                           
  Else                           
   (Select IsNull(SUM(Quantity * PurchasePrice), 0)                          
   From Batch_Products                           
   Where Product_Code = Items.Product_Code) +                           
   (Select IsNull(SUM(Pending * PurchasePrice), 0)                        
   From VanStatementDetail, VanStatementAbstract                           
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                           
   And (VanStatementAbstract.Status & 128) = 0                           
   And VanStatementDetail.Product_Code = Items.Product_Code)                         
  End,                       
 "Pending Orders" =(IsNull(dbo.GetPOPending (Items.Product_Code), 0) + IsNull(dbo.GetSRPending(Items.Product_Code), 0))                
From             
 Items, OpeningDetails,ItemCategories,Manufacturer                         
WHERE               
 Items.Product_Code *= OpeningDetails.Product_Code And                      
 DBO.STRIPDATEFROMTIME(OpeningDetails.Opening_Date) = @FromDATE  And                    
 items.ManufacturerID = Manufacturer.ManufacturerID And                 
 Items.CategoryID = ItemCategories.CategoryID And                   
Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr) And                 
 Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpProd)                
     
Select             
 Itemcode1,"Item Code" = Itemcode,"Item Name" = ItemName,"Category Name" = CategoryName,"Opening Quantity" = Sum(OpeningQuantity ),"Free Opening Quantity" = Sum(FreeOpeningQuantity),"Damage Opening Quantity" = Sum(DamageOpeningQuantity),              
 "Total Opening Value" = Sum(TotalOpeningValue),"Opening Value" = Sum(OpeningValue),"Damage Opening Value" = Sum(DamageOpeningValue),"Total Opening Value" = Sum(TotalOpeningValue1),"Purchase" = Sum(Purchase),              
 "FreePurchase" = Sum(FreePurchase),"Sales Return Saleable" = Sum(SalesReturnSaleable),"Sale Return Damages" = Sum(SaleReturnDamages),              
 "Total Issues" = Sum(TotalIssues),"Salable Issues" = Sum(SalableIssues),"Free Issues" = Sum(FreeIssues),"Sales Value" = Sum(SalesValue),"Purchas Return" = Sum(PurchasReturn),"Adjustments" = Sum(Adjustments),              
 "Stock Transfer Out" = Sum(StockTransferOut),"Stock Transfer In" = Sum(StockTransferIn),"Stock Destruction" = Sum(StockDestruction),"On Hand Qty" = Sum(OnHandQty),"On Hand Free Qty" = Sum(OnHandFreeQty),"On Hand DamageQty" = Sum(OnHandDamageQty),       
  
    
 "Total On Hand Qty" = Sum(TotalOnHandQty),"On Hand Value" = Sum(OnHandValue),"On Hand Damages Value" = Sum(OnHandDamagesValue),"Total On Hand Value" = Sum(TotalOnHandValue),"Pending Orders" = Sum(PendingOrders)             
From             
 #Temp1              
Group By             
 Itemcode,ItemName,CategoryName,Itemcode1              
 

Drop Table #Temp              
Drop Table #Temp1              
Drop table #TmpMfr              
Drop table #TmpProd
