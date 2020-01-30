CREATE PROCEDURE [dbo].[spr_list_Companywise_Itemwise_Stock_Movement_Detail_Chevorn]            
(            
 @CompanyID NVarChar(15),            
 @Manufacturer NVarChar(2550),            
 @UnUsed NVarChar(2550),            
 @FromDate DateTime,            
 @ToDate DateTime            
)                      
As                      
          
Declare @NEXT_DATE DateTime                          
Declare @CORRECTED_DATE DateTime                          
          
Set @CORRECTED_DATE = Cast(DATEPART(dd, @TODATE) As NVarChar) + '/'+ Cast(DATEPART(mm, @TODATE) As NVarChar) + '/'+ Cast(DATEPART(yyyy, @TODATE) As NVarChar)                          
Set  @NEXT_DATE = Cast(DATEPART(dd, GETDATE()) As NVarChar) + '/' + Cast(DATEPART(mm, GETDATE()) As NVarChar) + '/'+ Cast(DATEPART(yyyy, GETDATE()) As NVarChar)                          
                
Declare @Delimeter As Char(1)                  
Set @Delimeter=Char(15)                     
          
Declare  @CIDSetUp As NVarChar(15)            
Select @CIDSetUp=RegisteredOwner From Setup                
            
Create table #TmpMfr(Manufacturer NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_As)                  
If @Manufacturer= N'%'                         
 Insert into #TmpMfr Select Manufacturer_Name From Manufacturer                        
Else                        
 Insert into #TmpMfr Select * From dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)             
            
If @CompanyID<>@CIDSetUp            
 Begin            
  Select                 
   "Item Code" = ReportAbstractReceived.Field1,
			"Item Code" = ReportAbstractReceived.Field1,                  
   "Item Name" = ReportAbstractReceived.Field2,                      
   "Category Name" =             
    Case             
     When ((Min(ReportAbstractReceived.Field3)) <> (Max(ReportAbstractReceived.Field3))) Then 'CATEGORY MISMATCH'                  
     Else Max(ReportAbstractReceived.Field3)                  
    End,                  
   "Opening Quantity" = Sum(Cast (ReportAbstractReceived.Field5 As Decimal(18,2))),                    
   "Free Opening Quantity" = Sum(Cast (ReportAbstractReceived.Field6 As Decimal(18,2))),                    
   "Damage Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field7 As Decimal(18,2))),                    
   "Total Opening Quantity" = Sum(Cast (ReportAbstractReceived.Field8 As Decimal(18,2))),                    
   "Opening Value (%c)" = Sum(Cast (ReportAbstractReceived.Field9 As Decimal(18,2))),                    
   "Damage Opening Value (%c)" = Sum(Cast(ReportAbstractReceived.Field10 As Decimal(18,2))),                    
   "Total Opening Value (%c)" = Sum(Cast(ReportAbstractReceived.Field11 As Decimal(18,2))),                    
   "Purchase" = Sum(Cast (ReportAbstractReceived.Field12 As Decimal(18,2))),                    
   "Free Purchase" = Sum(Cast (ReportAbstractReceived.Field13 As Decimal(18,2))),                    
   "Sales Return Saleable" = Sum(Cast (ReportAbstractReceived.Field14 As Decimal(18,2))),                    
   "Sales Return Damages" = Sum(Cast (ReportAbstractReceived.Field15 As Decimal(18,2))),                    
   "Total Issues" = Sum(Cast(ReportAbstractReceived.Field16 As Decimal(18,2))),                
   "Salable Issues" = Sum(Cast(ReportAbstractReceived.Field17 As Decimal(18,2))),                     
   "Free Issues" = Sum(Cast(ReportAbstractReceived.Field18 As Decimal(18,2))),                    
   "Sales Value (%c)" = Sum(Cast(ReportAbstractReceived.Field19 As Decimal(18,2))),                    
   "Purchase Return" = Sum(Cast(ReportAbstractReceived.Field20 As Decimal(18,2))),                    
   "Adjustments" = Sum(Cast (ReportAbstractReceived.Field21 As Decimal(18,2))),                    
   "Stock Transfer Out" = CASE       
  WHEN Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) > Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) THEN Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) - Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6)))  
 					 Else Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6)))  END,                          
   "Stock Transfer In" =  CASE       
  WHEN Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) > Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) THEN Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) - Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6)))  
 						Else Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6)))  END,      
   "Stock Destruction" = Sum(Cast (ReportAbstractReceived.Field24 As Decimal(18,2))),                
   "On Hand Qty" = Sum(Cast (ReportAbstractReceived.Field25 As Decimal(18,2))),                    
   "On Hand Free Qty" = Sum(Cast (ReportAbstractReceived.Field26 As Decimal(18,2))),                    
   "On Hand Damage Qty" = Sum(Cast (ReportAbstractReceived.Field27 As Decimal(18,2))),                    
   "Total On Hand Qty" = Sum(Cast(ReportAbstractReceived.Field28 As Decimal(18,2))),                    
   "On Hand Value (%c)" = Sum(Cast (ReportAbstractReceived.Field29 As Decimal(18,2))),                    
   "On Hand Damages Value (%c)" = Sum(Cast (ReportAbstractReceived.Field30 As Decimal(18,2))),                    
   "Total On Hand Value (%c)" = Sum(Cast (ReportAbstractReceived.Field31 As Decimal(18,2))),                
   "Pending Orders" = Sum(Cast(ReportAbstractReceived.Field32 As Decimal(18,2))),            
   "Forum Code" = ReportAbstractReceived.Field33            
  From             
   Reports, ReportAbstractReceived,Items,Manufacturer                         
  Where             
   Reports.ReportID In             
   (            
    Select             
     Max(ReportID)             
    From             
     Reports             
    Where             
     ReportName = N'Stock Movement - Item'                   
     And ParameterID In (Select ParameterID From Dbo.GetReportParameters2('Stock Movement - Item')                   
      Where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate))                  
   Group By CompanyID)                  
   And ReportAbstractReceived.ReportID = Reports.ReportID                
   And Reports.CompanyID= @CompanyID                 
   And Field1 <> N'Item Code'             
   And Field1 <> N'SubTotal:'             
   And Field1 <> N'GrAndTotal:'             
   And Items.ManufacturerID = Manufacturer.ManufacturerID             
   And Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)             
   And Field1=Items.Product_Code            
  Group By             
   ReportAbstractReceived.Field1,ReportAbstractReceived.Field2,ReportAbstractReceived.Field33            
  Order By            
   "Item Name"               
 End            
Else            
 Begin            
  Select                
   Items.Product_Code,"Item Code" = Items.Product_Code,"Item Name" = ProductName,                           
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
    And GRNAbstract.GRNDate BETWEEN @FromDATE And @TODATE And                           
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
    And Dbo.Stripdatefromtime(InvoiceAbstract.InvoiceDate) BETWEEN @FromDATE And @TODATE), 0)                           
    + IsNull((Select SUM(Quantity)                           
    From DispatchDetail, DispatchAbstract                           
    Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                            
    And IsNull(DispatchAbstract.Status, 0) & 64 = 0                        
    And DispatchDetail.Product_Code = Items.Product_Code                           
    And Dbo.Stripdatefromtime(DispatchAbstract.DispatchDate) BETWEEN @FromDATE And @TODATE), 0)),                
   "Saleable Issues" =              
    (IsNull((Select SUM(Quantity) From InvoiceDetail, InvoiceAbstract                  
    Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                           
    And (InvoiceAbstract.InvoiceType = 2)                           
    And (InvoiceAbstract.Status & 128) = 0              
    And InvoiceDetail.Product_Code = Items.Product_Code                           
    And InvoiceDetail.SalePrice > 0                       
    And (InvoiceAbstract.Status & 32) = 0                          
    And InvoiceAbstract.InvoiceDate BETWEEN @FromDATE And @TODATE), 0)                      
    + IsNull((Select SUM(Quantity)            
    From DispatchDetail, DispatchAbstract                           
    Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                           
    And (DispatchAbstract.Status & 64) = 0                           
    And DispatchDetail.Product_Code = Items.Product_Code                           
    And DispatchAbstract.DispatchDate BETWEEN @FromDATE And @TODATE                          
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
   "Stock Transfer Out" =case  when                 
  (IsNull((Select Sum(Quantity)                         
  From StockTransferOutAbstract, StockTransferOutDetail                        
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                      
  StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate              
  And StockTransferOutAbstract.Status & 192 = 0                        
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) >   (IsNull((Select Sum(Quantity)                         
  From StockTransferInAbstract, StockTransferInDetail                         
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                        
  And StockTransferInAbstract.DocumentDate Between @FromDate And  @ToDate              
  And StockTransferInAbstract.Status & 192 = 0                        
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) then   (IsNull((Select Sum(Quantity)                         
  From StockTransferOutAbstract, StockTransferOutDetail                        
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                      
  StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate              
  And StockTransferOutAbstract.Status & 192 = 0                        
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) -   (IsNull((Select Sum(Quantity)                         
  From StockTransferInAbstract, StockTransferInDetail                         
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                        
  And StockTransferInAbstract.DocumentDate Between @FromDate And  @ToDate              
  And StockTransferInAbstract.Status & 192 = 0                        
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) Else (IsNull((Select Sum(Quantity)                         
  From StockTransferOutAbstract, StockTransferOutDetail                        
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                      
  StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate              
  And StockTransferOutAbstract.Status & 192 = 0                        
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) End  ,              
 "Stock Transfer In" = Case When                  
  (IsNull((Select Sum(Quantity)                         
  From StockTransferInAbstract, StockTransferInDetail                         
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                        
  And StockTransferInAbstract.DocumentDate Between @FromDate And  @ToDate              
  And StockTransferInAbstract.Status & 192 = 0                        
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) > (IsNull((Select Sum(Quantity)                         
  From StockTransferOutAbstract, StockTransferOutDetail                        
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                      
  StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate              
  And StockTransferOutAbstract.Status & 192 = 0                        
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) Then (IsNull((Select Sum(Quantity)                         
  From StockTransferInAbstract, StockTransferInDetail              
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                        
  And StockTransferInAbstract.DocumentDate Between @FromDate And  @ToDate              
  And StockTransferInAbstract.Status & 192 = 0                        
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) - (IsNull((Select Sum(Quantity)                         
  From StockTransferOutAbstract, StockTransferOutDetail                        
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                      
  StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate              
  And StockTransferOutAbstract.Status & 192 = 0                        
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0))Else (IsNull((Select Sum(Quantity)                         
  From StockTransferInAbstract, StockTransferInDetail                         
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                        
  And StockTransferInAbstract.DocumentDate Between @FromDate And  @ToDate              
  And StockTransferInAbstract.Status & 192 = 0                        
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) End ,              
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
     And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0)))                
    End,                  
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
     From OpeningDetails                           
     Where OpeningDetails.Product_Code = Items.Product_Code                           
     And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                          
    Else                           
     (Select IsNull(SUM(Quantity * PurchasePrice), 0)    
     From Batch_Products                           
     Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)                          
    End,                           
   "Total On Hand Value (%c)" =             
    Case When (@TODATE < @NEXT_DATE) THEN                           
     IsNull((Select Opening_Value                          
     From OpeningDetails                           
     Where OpeningDetails.Product_Code = Items.Product_Code                           
     And Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0)                          
    Else                           
     ((Select IsNull(SUM(Quantity * PurchasePrice), 0)                           
     From Batch_Products                           
     Where Product_Code = Items.Product_Code) +                    
     (Select IsNull(SUM(Pending * PurchasePrice), 0)                           
     From VanStatementDetail, VanStatementAbstract                           
     Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                           
     And (VanStatementAbstract.Status & 128) = 0  
    And VanStatementDetail.Product_Code = Items.Product_Code))                          
    End,                       
   "Pending Orders" =(IsNull(dbo.GetPOPending (Items.Product_Code), 0) + IsNull(dbo.GetSRPending(Items.Product_Code), 0)),            
   "Forum Code" = Items.Alias            
  From             
   Items, OpeningDetails,Manufacturer,ItemCategories,Setup                      
  Where               
   Items.Product_Code *= OpeningDetails.Product_Code             
   And OpeningDetails.Opening_Date = @FromDATE                        
   And Items.ManufacturerID = Manufacturer.ManufacturerID             
   And Setup.RegisteredOwner = @CompanyId                      
   And Items.CategoryID = ItemCategories.CategoryID               
   And Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr)             
 Order By            
   "Item Name"            
 End
