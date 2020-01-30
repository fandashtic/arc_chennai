CREATE procedure [dbo].[spr_Itemwise_Companywise_Stock_Movement_Detail_Chevron]               
(            
 @ItemAndManufact NVarChar(100),              
 @UnUsed1 NVarChar(100),              
 @UnUsed2 NVarChar(100),        
 @FromDateBh DateTime,              
 @ToDateBh DateTime              
        
)              
As              
                  
Declare @NEXT_DATE DateTime                        
Declare @CORRECTED_DATE DateTime                        
SET @CORRECTED_DATE = Cast(DatePart(dd, @TODATEBh) AS NVarChar) + '/'+ Cast(DatePart(mm, @TODATEBh) as NVarChar) + '/'+ Cast(DatePart(yyyy, @TODATEBh) AS NVarChar)                        
SET  @NEXT_DATE = Cast(DatePart(dd, GetDate()) AS NVarChar) + '/'+ Cast(DatePart(mm, GetDate()) as NVarChar) + '/' + Cast(DatePart(yyyy, GetDate()) AS NVarChar)                        
                
Declare @ProductCode NVarChar(255)                    
Declare @Manufacturer NVarChar(255)                    
Declare @Pos int                    
                    
Set @Pos = charindex(';', @ItemAndManufact)                    
Set @ProductCode = substring(@ItemAndManufact, 1, @Pos-1)                     
Set @Manufacturer = substring(@ItemAndManufact, @Pos + 1, 255)                    
              
Select             
 Reports.CompanyID,Reports.CompanyID,               
 "Item Code" = ReportAbstractReceived.Field1,                
 "Item Name" = ReportAbstractReceived.Field2,                    
 "Category Name" =             
  Case             
   When ((Min(ReportAbstractReceived.Field3)) <> (Max(ReportAbstractReceived.Field3))) Then 'CATEGORY MISMATCH'                
   Else Max(ReportAbstractReceived.Field3)                
  End,                
 "Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field5 as Decimal(18,6))),                  
 "Free Opening Quantity" = Sum(Cast(ReportAbstractReceived.Field6 as Decimal(18,6))),                  
 "Damage Opening Quantity" = Sum(Cast (ReportAbstractReceived.Field7 as Decimal(18,6))),                  
 "Total Opening Quantity" = Sum(Cast (ReportAbstractReceived.Field8 as Decimal(18,6))),                  
 "Opening Value" = Sum(Cast (ReportAbstractReceived.Field9 as Decimal(18,6))),                  
 "Damage Opening Value" = Sum(Cast (ReportAbstractReceived.Field10 as Decimal(18,6))),                  
 "Total Opening Value" = Sum(Cast(ReportAbstractReceived.Field11 as Decimal(18,6))),                  
 "Purchase" = Sum(Cast(ReportAbstractReceived.Field12 as Decimal(18,6))),                  
 "Free Purchase" = Sum(Cast (ReportAbstractReceived.Field13 as Decimal(18,6))),                  
 "Sales Return Saleable" = Sum(Cast (ReportAbstractReceived.Field14 as Decimal(18,6))),                  
 "Sales Return Damages" = Sum(Cast (ReportAbstractReceived.Field15 as Decimal(18,6))),                  
 "Total Issues" = Sum(Cast (ReportAbstractReceived.Field16 as Decimal(18,6))),              
 "Salable Issues" = Sum(Cast (ReportAbstractReceived.Field17 as Decimal(18,6))),                   
 "Free Issues" = Sum(Cast(ReportAbstractReceived.Field18 as Decimal(18,6))),                  
 "Sales Value " = Sum(Cast (ReportAbstractReceived.Field19 as Decimal(18,6))),                  
 "Purchase Return" = Sum(Cast (ReportAbstractReceived.Field20 as Decimal(18,6))),                  
 "Adjustments" = Sum(Cast (ReportAbstractReceived.Field21 as Decimal(18,6))),                  
 "Stock Transfer Out" = CASE       
  WHEN Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) > Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) THEN Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) - Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6)))  
  Else Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6)))  END,                          
 "Stock Transfer In" =  CASE       
  WHEN Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) > Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))) THEN (Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6))) - Sum(Cast(ReportAbstractReceived.Field22 as Decimal(18,6))))   
  Else Sum(Cast(ReportAbstractReceived.Field23 as Decimal(18,6)))  END,      
 "Stock Destruction" = Sum(Cast(ReportAbstractReceived.Field24 as Decimal(18,6))),              
 "On Hand Qty" = Sum(Cast (ReportAbstractReceived.Field25 as Decimal(18,6))),                  
 "On Hand Free Qty" = Sum(Cast (ReportAbstractReceived.Field26 as Decimal(18,6))),                  
 "On Hand Damage Qty" = Sum(Cast (ReportAbstractReceived.Field27 as Decimal(18,6))),                  
 "Total On Hand Qty" = Sum(Cast (ReportAbstractReceived.Field28 as Decimal(18,6))),                  
 "On Hand Value" = Sum(Cast (ReportAbstractReceived.Field29 as Decimal(18,6))),                  
 "On Hand Damages Value" = Sum(Cast (ReportAbstractReceived.Field30 as Decimal(18,6))),                  
 "Total On Hand Value" = Sum(Cast (ReportAbstractReceived.Field31 as Decimal(18,6))),              
 "Pending Orders" = Sum(Cast(ReportAbstractReceived.Field32 as Decimal(18,6)))                              
From             
 Reports, ReportAbstractReceived                     
Where             
 Reports.ReportID in (Select ReportID From Reports Where ReportName = 'Stock Movement - Item'                 
  And ParameterID in (Select ParameterID From Dbo.GetReportParameters2('Stock Movement - Item')                 
  Where FromDate = dbo.StripDateFromTime(@FromDateBh) And ToDate = dbo.StripDateFromTime(@ToDateBh)))              
 And ReportAbstractReceived.Field1 = @ProductCode                  
 And ReportAbstractReceived.ReportID = Reports.ReportID                 
 And ReportAbstractReceived.Field3 <> 'Opening Quantity'                    
 And ReportAbstractReceived.Field1 <> 'SubTotal:'                  
 And ReportAbstractReceived.Field1 <> 'GrandTotal:'              
Group by             
 Reports.companyid,ReportAbstractReceived.Field1,ReportAbstractReceived.Field2              
                  
Union All              
              
SELECT              
CompanyID1 ='',              
CompanyID =Setup.RegisteredOwner,                
 "Item Code" = Items.Product_Code,                       
 "Item Name" = ProductName,                       
 "Category Name" = ItemCategories.Category_Name,              
 "Opening Quantity" = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0),              
 "Free Opening Quantity" = IsNull(Free_Saleable_Quantity, 0),            
 "Damage Opening Quantity" = IsNull(Damage_Opening_Quantity, 0),            
 "Total Opening Quantity" = IsNull(Opening_Quantity, 0),            
 "(%c) Opening Value" = IsNull(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),                      
 "(%c) Damage Opening Value" = IsNull(Damage_Opening_Value, 0),               
 "(%c) Total Opening Value" = IsNull(Opening_Value, 0),              
 "Purchase" =               
  (IsNull((Select Sum(QuantityReceived - QuantityRejected)                       
  From GRNAbstract, GRNDetail                       
  Where GRNAbstract.GRNID = GRNDetail.GRNID                       
  And GRNDetail.Product_Code = Items.Product_Code                       
  And GRNAbstract.GRNDate Between @FromDateBh And @ToDateBh          
  And (GRNAbstract.GRNStatus & 64) = 0           
  And   (GRNAbstract.GRNStatus & 32) = 0 ), 0)),            
 "Free Purchase" =               
  (IsNull((Select Sum(IsNull(FreeQty, 0))                       
  From GRNAbstract, GRNDetail                       
  Where GRNAbstract.GRNID = GRNDetail.GRNID                       
  And GRNDetail.Product_Code = Items.Product_Code                       
  And GRNAbstract.GRNDate Between @FromDateBh And @ToDateBh                    
  And (GRNAbstract.GRNStatus & 64) = 0           
  And (GRNAbstract.GRNStatus & 32) = 0 ), 0)),              
 "Sales Return Saleable" =                 
  (ISNULL((Select SUM(Quantity) From                 
  InvoiceDetail, InvoiceAbstract                         
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                         
  AND (InvoiceAbstract.InvoiceType = 4)                         
  AND (InvoiceAbstract.Status & 128) = 0                         
  AND InvoiceDetail.Product_Code = Items.Product_Code      
  AND (InvoiceAbstract.Status & 32) = 0                        
  AND InvoiceAbstract.InvoiceDate Between @FromDateBh And  @ToDateBh), 0)          
  +                 
  ISNULL((Select SUM(Quantity) From                 
  InvoiceDetail, InvoiceAbstract                         
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                         
  AND (InvoiceAbstract.InvoiceType = 5)                         
  AND (InvoiceAbstract.Status & 128) = 0                         
  AND InvoiceDetail.Product_Code = Items.Product_Code                         
  AND InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh), 0)),               
 "Sales Return Damages" =               
  (IsNull((Select Sum(Quantity) From               
  InvoiceDetail, InvoiceAbstract               
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                    
  And (InvoiceAbstract.InvoiceType = 4)                       
  And (InvoiceAbstract.Status & 128) = 0                       
  And InvoiceDetail.Product_Code = Items.Product_Code                       
  And (InvoiceAbstract.Status & 32) <> 0                      
  AND InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh), 0) +               
  IsNull((Select Sum(Quantity) From               
  InvoiceDetail, InvoiceAbstract               
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
  And (InvoiceAbstract.InvoiceType = 6)                       
  And (InvoiceAbstract.Status & 128) = 0                       
  And InvoiceDetail.Product_Code = Items.Product_Code                       
  AND InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh), 0)),            
 "Total Issues" =               
  (IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract               
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
  And (InvoiceAbstract.InvoiceType = 2) And               
  (InvoiceAbstract.Status & 128) = 0 And               
  InvoiceDetail.Product_Code = Items.Product_Code                      
  AND InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBH), 0)                       
  + IsNull((Select Sum(Quantity)                       
  From DispatchDetail, DispatchAbstract                       
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                        
  And IsNull(DispatchAbstract.Status, 0) & 64 = 0                    
  And DispatchDetail.Product_Code = Items.Product_Code                       
  AND DispatchAbstract.DispatchDate Between @FromDateBh And  @ToDateBH), 0)),            
 "Saleable Issues" =               
  (IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract              
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
  And (InvoiceAbstract.InvoiceType = 2)                       
  And (InvoiceAbstract.Status & 128) = 0                      
  And InvoiceDetail.Product_Code = Items.Product_Code                       
  And InvoiceDetail.SalePrice > 0                   
  And (InvoiceAbstract.Status & 32) = 0                      
  And InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh),0)                  
  + IsNull((Select Sum(Quantity)                       
  From DispatchDetail, DispatchAbstract                       
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                       
  And (DispatchAbstract.Status & 64) = 0                       
  And DispatchDetail.Product_Code = Items.Product_Code                       
  And DispatchAbstract.DispatchDate Between @FromDateBh And  @ToDateBh            
  And DispatchDetail.SalePrice > 0), 0)),            
 "Free Issues" =               
  (IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract              
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
  And (InvoiceAbstract.InvoiceType = 2)                       
  And (InvoiceAbstract.Status & 128) = 0                       
  And InvoiceDetail.Product_Code = Items.Product_Code                       
  And InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh           
  And InvoiceDetail.SalePrice = 0), 0)                       
  + IsNull((Select Sum(Quantity)                       
  From DispatchDetail, DispatchAbstract                       
  Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID                       
  And (DispatchAbstract.Status & 64) = 0                       
  And DispatchDetail.Product_Code = Items.Product_Code                       
  And DispatchAbstract.DispatchDate Between @FromDateBh And  @ToDateBh             
  And DispatchDetail.SalePrice = 0), 0)),                 
 "Sales Value (%c)" =             
  IsNull((Select Sum(Case invoicetype When 4 Then 0 - Amount Else Amount End)                       
  From InvoiceDetail, InvoiceAbstract                       
  Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                       
  And (InvoiceAbstract.Status & 128) = 0                       
  And InvoiceDetail.Product_Code = Items.Product_Code                       
  And InvoiceAbstract.InvoiceDate Between @FromDateBh And @ToDateBh), 0),                         
 "Purchase Return" =               
  (IsNull((Select Sum(Quantity)                       
  From AdjustmentReturnDetail, AdjustmentReturnAbstract                       
  Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID          
  And AdjustmentReturnDetail.Product_Code = Items.Product_Code                       
  And AdjustmentReturnAbstract.AdjustmentDate Between @FromDateBh And @ToDateBh            
  And (IsNull(AdjustmentReturnAbstract.Status, 0) & 64) = 0                  
  And (IsNull(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)),            
 "Adjustments" =               
  (IsNull((Select Sum(Quantity - OldQty)                       
 From StockAdjustment, StockAdjustmentAbstract                       
  Where IsNull(AdjustmentType,0) in (1, 3)                       
  And Product_Code = Items.Product_Code                       
  And StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                      
  And StockAdjustmentAbstract.AdjustmentDate Between @FromDateBh And  @ToDateBh), 0)),            
 "Stock Transfer Out" =case  when               
  (IsNull((Select Sum(Quantity)                       
  From StockTransferOutAbstract, StockTransferOutDetail                      
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                    
  StockTransferOutAbstract.DocumentDate Between @FromDateBh And @ToDateBh            
  And StockTransferOutAbstract.Status & 192 = 0                      
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) >   (IsNull((Select Sum(Quantity)                       
  From StockTransferInAbstract, StockTransferInDetail                       
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
  And StockTransferInAbstract.DocumentDate Between @FromDateBh And  @ToDateBh            
  And StockTransferInAbstract.Status & 192 = 0                      
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) then   (IsNull((Select Sum(Quantity)                       
  From StockTransferOutAbstract, StockTransferOutDetail                      
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                    
  StockTransferOutAbstract.DocumentDate Between @FromDateBh And @ToDateBh            
  And StockTransferOutAbstract.Status & 192 = 0                      
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) -   (IsNull((Select Sum(Quantity)                       
  From StockTransferInAbstract, StockTransferInDetail                       
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
  And StockTransferInAbstract.DocumentDate Between @FromDateBh And  @ToDateBh            
  And StockTransferInAbstract.Status & 192 = 0                      
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) Else (IsNull((Select Sum(Quantity)                       
  From StockTransferOutAbstract, StockTransferOutDetail                      
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                    
  StockTransferOutAbstract.DocumentDate Between @FromDateBh And @ToDateBh            
  And StockTransferOutAbstract.Status & 192 = 0                      
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) End  ,            
 "Stock Transfer In" = Case When                
  (IsNull((Select Sum(Quantity)                       
  From StockTransferInAbstract, StockTransferInDetail                       
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
  And StockTransferInAbstract.DocumentDate Between @FromDateBh And  @ToDateBh            
  And StockTransferInAbstract.Status & 192 = 0                      
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) > (IsNull((Select Sum(Quantity)                       
  From StockTransferOutAbstract, StockTransferOutDetail                      
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                    
  StockTransferOutAbstract.DocumentDate Between @FromDateBh And @ToDateBh            
  And StockTransferOutAbstract.Status & 192 = 0                      
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)) Then (IsNull((Select Sum(Quantity)                       
  From StockTransferInAbstract, StockTransferInDetail                       
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
  And StockTransferInAbstract.DocumentDate Between @FromDateBh And  @ToDateBh            
  And StockTransferInAbstract.Status & 192 = 0                      
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) - (IsNull((Select Sum(Quantity)                       
  From StockTransferOutAbstract, StockTransferOutDetail                      
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And                    
  StockTransferOutAbstract.DocumentDate Between @FromDateBh And @ToDateBh            
  And StockTransferOutAbstract.Status & 192 = 0                      
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0))Else (IsNull((Select Sum(Quantity)                       
  From StockTransferInAbstract, StockTransferInDetail                       
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                      
  And StockTransferInAbstract.DocumentDate Between @FromDateBh And  @ToDateBh            
  And StockTransferInAbstract.Status & 192 = 0                      
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)) End ,            
 "Stock Destruction" =               
  (Cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                               
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote                   
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                              
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID                  
  And StockDestructionAbstract.DocumentDate Between @FromDateBh And  @ToDateBh         
  And ClaimsNote.Status & 1 <> 0                      
  And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))),             
 "On Hand Qty" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   (IsNull((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)              
   - IsNull(Damage_Opening_Quantity, 0) From OpeningDetails              
   Where OpeningDetails.Product_Code = Items.Product_Code               
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))              
  Else                       
   ((IsNull((Select Sum(Quantity)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And               
   IsNull(Damage, 0) = 0), 0) +                      
   (Select IsNull(Sum(Pending), 0)                       
   From VanStatementDetail, VanStatementAbstract                       
 Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
   And (VanStatementAbstract.Status & 128) = 0                       
   And VanStatementDetail.Product_Code = Items.Product_Code And               
   VanStatementDetail.PurchasePrice <> 0)))              
  End,                      
 "On Hand Free Qty" =               
  Case When (@ToDateBh < @Next_Date) Then                       
   (IsNull((Select IsNull(Free_Saleable_Quantity, 0)                      
   From OpeningDetails                       
   Where OpeningDetails.Product_Code = Items.Product_Code                       
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))              
  Else                     
   ((IsNull((Select Sum(Quantity)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                
   (Select IsNull(Sum(Pending), 0)                   
   From VanStatementDetail, VanStatementAbstract                       
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
   And (VanStatementAbstract.Status & 128) = 0                       
   And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0)))              
  End,                      
 "On Hand Damage Qty" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   (IsNull((Select IsNull(Damage_Opening_Quantity, 0)                      
   From OpeningDetails               
   Where OpeningDetails.Product_Code = Items.Product_Code                
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))              
  Else                       
   (IsNull((Select Sum(Quantity)               
   From Batch_Products                       
   Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))              
  End,                      
 "Total On Hand Qty" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   (IsNull((Select Opening_Quantity                      
   From OpeningDetails                       
   Where OpeningDetails.Product_Code = Items.Product_Code                       
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))              
  Else                       
   (IsNull((Select Sum(Quantity)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code), 0) +                      
   (Select IsNull(Sum(Pending), 0)                       
   From VanStatementDetail, VanStatementAbstract                       
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
   And (VanStatementAbstract.Status & 128) = 0                       
   And VanStatementDetail.Product_Code = Items.Product_Code))              
  End,                      
 "On Hand Value (%c)" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   IsNull((Select Opening_Value - IsNull(Damage_Opening_Value, 0)                      
   From OpeningDetails                       
   Where OpeningDetails.Product_Code = Items.Product_Code                       
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)                      
  Else                       
   ((Select IsNull(Sum(Quantity * PurchasePrice), 0)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +                       
   (Select IsNull(Sum(Pending * PurchasePrice), 0)          
   From VanStatementDetail, VanStatementAbstract                       
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
   And (VanStatementAbstract.Status & 128) = 0                       
   And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))                      
  End,                      
 "On Hand Damages Value (%c)" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   IsNull((Select IsNull(Damage_Opening_Value, 0)                      
   From OpeningDetails                       
   Where OpeningDetails.Product_Code = Items.Product_Code                       
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)                      
  Else                       
   (Select IsNull(Sum(Quantity * PurchasePrice), 0)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)                      
  End,                       
 "Total On Hand Value" =             
  Case When (@ToDateBh < @Next_Date) Then                       
   IsNull((Select Opening_Value                      
   From OpeningDetails                       
   Where OpeningDetails.Product_Code = Items.Product_Code                       
   And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)                      
  Else                       
   ((Select IsNull(Sum(Quantity * PurchasePrice), 0)                       
   From Batch_Products                       
   Where Product_Code = Items.Product_Code) +                       
   (Select IsNull(Sum(Pending * PurchasePrice), 0)                       
   From VanStatementDetail, VanStatementAbstract                       
   Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                       
   And (VanStatementAbstract.Status & 128) = 0                     
   And VanStatementDetail.Product_Code = Items.Product_Code))                      
  End,                   
 "Pending Orders" =            
  (IsNull(dbo.GetPOPending (Items.Product_Code), 0) +                   
  IsNull(dbo.GetSRPending(Items.Product_Code), 0))                 
FROM             
 Items, OpeningDetails,Manufacturer, ItemCategories,Setup                    
WHERE               
 Items.Product_Code *= OpeningDetails.Product_Code AND                      
 OpeningDetails.Opening_Date = @FROMDATEBh   And         
 Items.ManufacturerID =  Manufacturer.ManufacturerID  And           
 Items.ManufacturerID =  @Manufacturer And                      
 Items.CategoryID = ItemCategories.CategoryID And                
 Items.Product_Code = @ProductCode
