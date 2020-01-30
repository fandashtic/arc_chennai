CREATE procedure [dbo].[spr_ser_Stock_Sales_Register_detail]( @PRODUCT_CODE nvarchar(500),     
--              @PRODUCT_NAME VarChar(255),     
              @FROMDATE datetime,     
              @TODATE datetime)                  
as                  
declare @NEXT_DATE datetime                  
DECLARE @CORRECTED_DATE datetime                  
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS varchar) + '/' + CAST(DATEPART(mm, @TODATE) as varchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS varchar)                  
SET @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS varchar) + '/' + CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as varchar) + '/' + cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS varchar)                  
----------                
DECLARE @PROD_UOM NVARCHAR(100)                
DECLARE @ITEM NVARCHAR(15)                
DECLARE @UOM NVARCHAR(50)                    
DECLARE @LENSTR INT                    
DECLARE @LENSTR2 INT                    
                
SET @PROD_UOM = @PRODUCT_CODE                
SET @LENSTR = (CHARINDEX(',', @PROD_UOM) )                     
SELECT @ITEM = SUBSTRING(@PROD_UOM,  1 , (@lENSTR - 1 ))                  
SET @LENSTR2 = (CHARINDEX(',', @PROD_UOM, @LENSTR + 1) )                     
SELECT @UOM = SUBSTRING(@PROD_UOM, (@lENSTR + 1) , @lENSTR2 - @LENSTR - 1 )                    
SET @PRODUCT_CODE = @ITEM                
-------------                
if @UOM = 'Sales UOM'                              
begin                              
 SELECT  1,                  
 "Opening Date" = OpeningDetails.Opening_Date,                  
 "Total Opening Quantity" =  cast (ISNULL(Opening_Quantity, 0) as Decimal(18,6)),                  
 "Saleable Opening Quantity" = cast(ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) as Decimal(18,6)),          
 "Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) as Decimal(18,6)),                  
 "Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) as Decimal(18,6)),                   
         
 "Opening Value" =  cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),            
 "Purchase" =   cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 And (GrnAbstract.GRNStatus &32)=0), 0)  as Decimal(18,6)),                  
          
 "Free Purchase" = cast (ISNULL((SELECT SUM(FreeQty)          
-- "Purchase" =   cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0))          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 And (GRNAbstract.GRNStatus & 32)=0), 0)  as Decimal(18,6)),                  
    
 "Total Sales Return" = cast ( ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In(4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) as Decimal(18,6)),              
      
"Sales Return Saleable" = cast ( ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)       
AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.Product_Code = Items.Product_Code      
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) +     
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.Product_Code = Items.Product_Code      
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) as Decimal(18,6)),       
      
"Sales Return Damages" = cast ( ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) <> 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) +     
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0 --And (InvoiceAbstract.Status & 32) <> 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) as Decimal(18,6)),       
                    
 "Issues" = cast (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192  = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code AND
 IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''  And   
 ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
 DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND DispatchDetail.Product_Code = Items.Product_Code                   
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date             
  AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) as Decimal(18,6)),            
    
 "Saleable Issues" = cast ( ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 2)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceDetail.Product_Code = Items.Product_Code                
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) as Decimal(18,6))    
    
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
AND serviceInvoiceDetail.sparecode = items.product_code    
AND Isnull(ServiceInvoiceDetail.Price,0) <> 0        
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date             
AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
    
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND                   
  DispatchDetail.Product_Code = Items.Product_Code AND                  
  DispatchDetail.SalePrice > 0                  
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date             
  AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0),            
            
 "Free Issues" = cast (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceDetail.SalePrice = 0 AND                  
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code    
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND                   
  DispatchDetail.Product_Code = Items.Product_Code AND                  
  DispatchDetail.SalePrice = 0                  
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date             
  AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)  as Decimal(18,6)),            
                   
 "Purchase Return" = cast (ISNULL((SELECT SUM(Quantity)              
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                  
  AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                 
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)     
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)  as Decimal(18,6)),                   
                   
 "Adjustments" = cast ( ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND                   
  StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
  AND AdjustmentDate BETWEEN OpeningDetails.Opening_Date             
  And DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)  as Decimal(18,6)),                  
                   
 "Stock Transfer Out" = cast (IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)                   
  And StockTransferOutDetail.Product_Code = Items.Product_Code and  StockTransferOutAbstract.Status & 192 = 0), 0)  as Decimal(18,6)),                  
                   
 "Stock Transfer In" = cast (IsNull((Select Sum(Quantity)                   
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)                   
  And StockTransferInDetail.Product_Code = Items.Product_Code  And StockTransferInAbstract.Status & 192 = 0), 0)  as Decimal(18,6)),                  
  
       
  "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
  And ClaimsNote.Status & 1 <> 0            
  and Items.product_code like @Item            
  And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),    
    
    
 "On Hand Qty" =  cast (CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Opening_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code), 0)
+   
Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM  
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0 ),0)              

+(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                       
  And VanStatementDetail.Product_Code = Items.Product_Code))  
end as Decimal(18,6)),                 
      
"On Hand Saleable Qty" = cast (CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                    
 ISNULL((Select o1.Opening_Quantity - IsNull(o1.Free_Saleable_Quantity, 0) - IsNull(o1.Damage_Opening_Quantity, 0) FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0)

+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM  
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
and Isnull(Issuedetail.SalePrice,0) <> 0),0)             

 +(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                       
 AND vanstatementdetail.purchaseprice <> 0    
 And VanStatementDetail.Product_Code = Items.Product_Code)) 

end as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast (CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Free_Saleable_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)              
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0)                       
+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM  
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
and Isnull(Issuedetail.SalePrice,0) = 0),0)
+ (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0       
 AND vanstatementdetail.purchaseprice = 0                    
 And VanStatementDetail.Product_Code = Items.Product_Code))
            
end as Decimal(18,6)),                  
     
         
 "On Hand Damage Qty" = cast (CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Damage_Opening_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)) end  as Decimal(18,6)),                  
    
-- Damage Qty is not exist in VAN    
--+(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
-- WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
-- (VanStatementAbstract.Status & 128) = 0                        
-- And VanStatementDetail.Product_Code = Items.Product_Code)) end  as Decimal(18,6)),       
             
 "On Hand Value" = cast ( CASE                   
  when (OpeningDetails.Opening_Date < @NEXT_DATE) THEN              
  ISNULL((Select o1.Opening_Value                   
  FROM OpeningDetails o1        
  WHERE o1.Product_Code = Items.Product_Code                   
  AND o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                  
  ELSE                   
  ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                   
  FROM Batch_Products                   
  WHERE Product_Code = Items.Product_Code) 

 + Isnull((SELECT Sum((Isnull(IssuedQty,0) - Isnull(ReturnedQty,0)) * Isnull(Issuedetail.Purchaseprice,0)) from
	Issuedetail,IssueAbstract,JobcardAbstract
	where IssueAbstract.IssueID =IssueDetail.IssueID And
	IssueAbstract.JobCardId = JobcardAbstract.JobcardID 
        And Issuedetail.SpareCode = Items.Product_Code
	And Isnull(IssueAbstract.Status,0) & 192  = 0
	and Isnull(jobcardAbstract.status,0) & 192 = 0 
	and Isnull(jobcardAbstract.status,0) & 32 = 0),0)                   

+  (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                   
  FROM VanStatementDetail, VanStatementAbstract                   
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
  AND (VanStatementAbstract.Status & 128) = 0                   
  And VanStatementDetail.Product_Code = Items.Product_Code))                  
 end  as Decimal(18,6))            
                 
 FROM   Items, OpeningDetails , UOM                  
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND                  
  OpeningDetails.Opening_Date between @FROMDATE and @TODATE                  
  AND Items.UOM *= UOM.UOM                  
  AND Items.Product_Code = @PRODUCT_CODE                  
  And IsNull(Items.Active,0) = 1                  
 group  By  OpeningDetails.Opening_Date,items.product_code,      
       OpeningDetails.Opening_Quantity, uom.description, Opening_Value,      
 OpeningDetails.Damage_Opening_Quantity, OpeningDetails.Free_Saleable_Quantity    
end                
-- changed                
Else if @UOM = 'Conversion Factor'                              
Begin                              
 SELECT  1,                  
 "Opening Date" = OpeningDetails.Opening_Date,                  
 "Total Opening Quantity" =  cast ((ISNULL(Opening_Quantity, 0)) * ISNULL(Items.ConversionFactor, 0)  as Decimal(18,6)),                   
 "Saleable Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0)) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),          
 "Free Opening Quantity" = cast (ISNULL(Free_Saleable_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                  
 "Damage Opening Quantity" = cast (ISNULL(Damage_Opening_Quantity, 0) *  ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                        
 "Opening Value" =  cast ( ISNULL(Opening_Value, 0)  as Decimal(18,6)),                  
 "Purchase" =   cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                   
  FROM GRNAbstract, GRNDetail             
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 and (GRNAbstract.GrnStatus & 32)=0), 0) *  ISNULL(Items.ConversionFactor, 0)  as Decimal(18,6)),                    
-- "Purchase" =   cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected + IsNull(FreeQty, 0))                   
 "Free Purchase" = cast (ISNULL((SELECT SUM(FreeQty)          
          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 And (GRnabstract.GRNStatus &32)=0), 0) *  ISNULL(Items.ConversionFactor, 0)  as Decimal(18,6)), 
    
"Total Sales Return" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
      
"Sales Return Saleable" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                    
 * ISNULL(Items.ConversionFactor, 0) +     
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
             
 "Sales Return Damages" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0                     
 AND InvoiceDetail.Product_Code = Items.Product_Code             
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                    
 * ISNULL(Items.ConversionFactor, 0) +     
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0     
 AND InvoiceDetail.Product_Code = Items.Product_Code             
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
            
 "Issues" = cast (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND            
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code and    
 IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' And    
 ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
 DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
    
+ (ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND DispatchDetail.Product_Code = Items.Product_Code                   
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                
  * (ISNULL(Items.ConversionFactor, 0))) as Decimal(18,6)),            
    
 "Saleable Issues" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType <> 4)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceDetail.Product_Code = Items.Product_Code                
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
AND serviceInvoiceDetail.sparecode = items.product_code    
AND Isnull(ServiceInvoiceDetail.Price,0) <> 0        
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date             
AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
 * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),              
                     
 "Free Issues" = cast (ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceDetail.SalePrice = 0 AND                  
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)              
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code    
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ (ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND                   
  DispatchDetail.Product_Code = Items.Product_Code AND                  
  DispatchDetail.SalePrice = 0                  
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0))                
  *    (ISNULL(Items.ConversionFactor, 0))  as Decimal(18,6)),                        
            
 "Purchase Return" = cast (ISNULL((SELECT SUM(Quantity)                   
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                   
  AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                   
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)     
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)                
  *    (ISNULL(Items.ConversionFactor, 0))  as Decimal(18,6)),                         
            
 "Adjustments" = cast ( ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND           
  StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID       
  AND AdjustmentDate BETWEEN OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                
  *    ISNULL(Items.ConversionFactor, 0)  as Decimal(18,6)),                        
            
 "Stock Transfer Out" = cast ( IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)    
  ANd StockTransferOutAbstract.Status & 192=0                 
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)                
  *    (ISNULL(Items.ConversionFactor, 0))  as Decimal(18,6)),                        
            
 "Stock Transfer In" = cast (IsNull((Select Sum(Quantity)                   
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)    
  And StockTransferInAbstract.Status &192=0                   
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)                
    *    (ISNULL(Items.ConversionFactor, 0))  as Decimal(18,6)),     
    
 "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
 From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
 Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
 And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
 And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
 And ClaimsNote.Status & 1 <> 0            
 and Items.product_code like @Item            
 And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),    
            
"On Hand Qty" =  cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN        
 ISNULL((Select o1.Opening_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract 
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                       
 And VanStatementDetail.Product_Code = Items.Product_Code))
+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM  
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0),0)              
 end)                
*(ISNULL(Items.ConversionFactor, 0))  as Decimal(18,6)),                       
                
 "On Hand Saleable Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Opening_Quantity - IsNull(o1.Free_Saleable_Quantity, 0) - IsNull(o1.Damage_Opening_Quantity, 0) FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0          
 AND vanstatementdetail.purchaseprice <> 0                 
 And VanStatementDetail.Product_Code = Items.Product_Code)) 
+Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) from   
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
And Isnull(Issuedetail.SalePrice,0) <> 0),0)
end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Free_Saleable_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                
 AND vanstatementdetail.purchaseprice = 0    
 And VanStatementDetail.Product_Code = Items.Product_Code)) 
+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) from   
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
And Isnull(Issuedetail.SalePrice,0) = 0),0)
end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                  
           
 "On Hand Damage Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Damage_Opening_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)     
 )end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),    
    
-- Damage Qty is not exist in VAN    
--+(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
-- WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
-- (VanStatementAbstract.Status & 128) = 0                       
-- And VanStatementDetail.Product_Code = Items.Product_Code)) end) * ISNULL(Items.ConversionFactor, 0) as Decimal(18,6)),                       
            
 "On Hand Value" = cast ( CASE                   
  when (OpeningDetails.Opening_Date < @NEXT_DATE) THEN                   
 ISNULL((Select o1.Opening_Value                   
  FROM OpeningDetails o1                   
  WHERE o1.Product_Code = Items.Product_Code     
  AND o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                  
  ELSE       
  ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)                   
  FROM Batch_Products                   
  WHERE Product_Code = Items.Product_Code) +                   
  (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                   
  FROM VanStatementDetail, VanStatementAbstract                   
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
  AND (VanStatementAbstract.Status & 128) = 0                   
  And VanStatementDetail.Product_Code = Items.Product_Code))

+Isnull((SELECT Sum((Isnull(IssuedQty,0) - Isnull(ReturnedQty,0)) * Isnull(Issuedetail.Purchaseprice,0)) from 
Issuedetail,IssueAbstract,JobcardAbstract
where IssueAbstract.IssueID =IssueDetail.IssueID And
IssueAbstract.JobCardId = JobcardAbstract.JobcardID 
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0
and Isnull(jobcardAbstract.status,0) & 192 = 0 
and Isnull(jobcardAbstract.status,0) & 32 = 0),0)
  end as Decimal(18,6))                            
 FROM   Items, OpeningDetails ,  ConversionTable                  
 WHERE    Items.Product_Code *= OpeningDetails.Product_Code AND                  
  OpeningDetails.Opening_Date between @FROMDATE and @TODATE                  
  AND Items.ConversionUnit *= ConversionTable.ConversionID                
  AND Items.Product_Code = @PRODUCT_CODE  And IsNull(Items.Active,0) = 1                  
 group  By  OpeningDetails.Opening_Date,items.product_code,                  
       OpeningDetails.Opening_Quantity, Items.ConversionFactor ,Opening_Value ,        
 OpeningDetails.Damage_Opening_Quantity, OpeningDetails.Free_Saleable_Quantity                   
end                              
else                              
begin                              
 SELECT  1,                  
 "Opening Date" = OpeningDetails.Opening_Date,                  
 "Total Opening Quantity" =  cast (ISNULL(Opening_Quantity, 0)              
      /  (CASE ISNULL(Items.ReportingUnit, 0)                     
      WHEN 0 THEN                     
      1                     
      ELSE                     
      ISNULL(Items.ReportingUnit, 0)                     
      END)  as Decimal(18,6)),                    
        
 "Saleable Opening Quantity" = cast ((ISNULL(Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)) /                   
 (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE                   
 ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)),                  
           
 "Free Opening Quantity" = cast (IsNull(Free_Saleable_Quantity, 0) /                   
 (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE                   
 ISNULL(Items.ReportingUnit, 0)            
 END) as Decimal(18,6)),                  
           
 "Damage Opening Quantity" = cast (IsNull(Damage_Opening_Quantity, 0)                  
 / (CASE ISNULL(Items.ReportingUnit, 0)                   
 WHEN 0 THEN                   
 1                   
 ELSE ISNULL(Items.ReportingUnit, 0) END) as Decimal(18,6)) ,            
         
 "Opening Value" =  cast (ISNULL(Opening_Value, 0) as Decimal(18,6)),                  
 "Purchase" =   cast ( ISNULL((SELECT SUM(QuantityReceived - QuantityRejected)                   
          
  FROM GRNAbstract, GRNDetail                   
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 and (Grnabstract.GRNStatus & 32)=0), 0)                
                  
  / (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),       
          
 "Free Purchase" =  cast ( ISNULL((SELECT SUM(FreeQty)                
  FROM GRNAbstract, GRNDetail     
  WHERE GRNAbstract.GRNID = GRNDetail.GRNID AND GRNDetail.Product_Code = Items.Product_Code AND                   
  GRNAbstract.GRNDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)                 
  And (GRNAbstract.GRNStatus & 64) = 0 and (GRNAbstract.GRNStatus &32)=0), 0)                            
  / (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                  
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                
    
              
 "Total Sales Return" = cast (ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType In (4, 5, 6))                     
 AND (InvoiceAbstract.Status & 128) = 0                      
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                   
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
       
 "Sales Return Saleable" = cast (ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) +     
 ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 5)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) = 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
 / (CASE ISNULL(Items.ReportingUnit, 0)            
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
      
 "Sales Return Damages" = cast (ISNULL((SELECT SUM(Quantity)                     
FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 4)                     
 AND (InvoiceAbstract.Status & 128) = 0  And (InvoiceAbstract.Status & 32) <> 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0) +     
 ISNULL((SELECT SUM(Quantity)                     
FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType = 6)                     
 AND (InvoiceAbstract.Status & 128) = 0  --And (InvoiceAbstract.Status & 32) <> 0                    
 AND InvoiceDetail.Product_Code = Items.Product_Code                     
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
 / (CASE ISNULL(Items.ReportingUnit, 0)                
 WHEN 0 THEN                     
 1           
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
           
 "Issues" = cast ((ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
    
+ ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code and    
IsNull(ServiceinvoiceDetail.SpareCode, '') <> '' And   
 ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
 DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
    
 + ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND DispatchDetail.Product_Code = Items.Product_Code                   
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0))                
  / (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                  
    
 "Saleable Issues" = cast(ISNULL((SELECT SUM(Quantity)                     
 FROM InvoiceDetail, InvoiceAbstract                     
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID                     
 AND (InvoiceAbstract.InvoiceType <> 4)                     
 AND (InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 32) = 0                  
 AND InvoiceDetail.SalePrice <> 0    
 AND InvoiceDetail.Product_Code = Items.Product_Code                
 AND InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date             
 AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
AND serviceInvoiceDetail.sparecode = items.product_code    
AND Isnull(ServiceInvoiceDetail.Price,0) <> 0        
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date             
AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)    
    
 / (CASE ISNULL(Items.ReportingUnit, 0)                     
 WHEN 0 THEN                     
 1                     
 ELSE                     
 ISNULL(Items.ReportingUnit, 0)                     
 END) as Decimal(18,6)),              
    
 "Free Issues" = cast ((ISNULL((SELECT SUM(Quantity) FROM InvoiceDetail, InvoiceAbstract                   
  WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND                   
  (InvoiceAbstract.InvoiceType = 2) AND (InvoiceAbstract.Status & 128) = 0 AND                   
  InvoiceDetail.Product_Code = Items.Product_Code AND                   
  InvoiceDetail.SalePrice = 0 AND                  
  InvoiceAbstract.InvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
  DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
  
 + ISNULL((SELECT SUM(Quantity)                         
 FROM ServiceInvoiceDetail, serviceInvoiceAbstract                         
 WHERE serviceInvoiceAbstract.serviceInvoiceID = serviceInvoiceDetail.serviceInvoiceID    
 AND (serviceInvoiceAbstract.serviceInvoiceType = 1)                         
 AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0                         
 AND serviceInvoiceDetail.sparecode = items.product_code    
and IsNull(ServiceinvoiceDetail.SpareCode, '') <> ''    
AND ISNULL(ServiceInvoiceDetail.Price, 0) = 0    
AND ServiceInvoiceAbstract.ServiceInvoiceDate BETWEEN OpeningDetails.Opening_Date AND                   
DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)     
    
+ ISNULL((SELECT SUM(Quantity) FROM DispatchDetail, DispatchAbstract                   
  WHERE DispatchAbstract.DispatchID = DispatchDetail.DispatchID AND                   
  (DispatchAbstract.Status & 64) = 0 AND                   
  DispatchDetail.Product_Code = Items.Product_Code AND                  
  DispatchDetail.SalePrice = 0                  
  AND DispatchAbstract.DispatchDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0))                  
                  
  / (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                  
 "Purchase Return" = cast ( ISNULL((SELECT SUM(Quantity)                   
  FROM AdjustmentReturnDetail, AdjustmentReturnAbstract                   
  WHERE AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID                   
  AND AdjustmentReturnDetail.Product_Code = Items.Product_Code                   
  AND AdjustmentReturnAbstract.AdjustmentDate BETWEEN OpeningDetails.Opening_Date AND DateAdd(hh, 24, OpeningDetails.Opening_Date)     
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 64) = 0    
And (ISNULL(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)                   
  /  (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                  
                   
 "Adjustments" = cast (ISNULL((SELECT SUM(Quantity - OldQty) FROM StockAdjustment, StockAdjustmentAbstract                   
  WHERE ISNULL(AdjustmentType,0) in (1, 3) And Product_Code = Items.Product_Code AND                   
  StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID                  
  AND AdjustmentDate BETWEEN OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)), 0)                
  /  (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),            
                  
 "Stock Transfer Out" = cast ( IsNull((Select Sum(Quantity)                   
  From StockTransferOutAbstract, StockTransferOutDetail                  
  Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial                  
  And StockTransferOutAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)                   
  And StockTransferOutAbstract.Status & 192=0    
  And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)                
  / (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                  
 "Stock Transfer In" = cast (IsNull((Select Sum(Quantity)                   
  From StockTransferInAbstract, StockTransferInDetail                   
  Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial                  
  And StockTransferInAbstract.DocumentDate Between OpeningDetails.Opening_Date And DateAdd(hh, 24, OpeningDetails.Opening_Date)                   
  And StockTransferInAbstract.Status & 192=0    
  And StockTransferInDetail.Product_Code = Items.Product_Code), 0)                  
  /   (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END) as Decimal(18,6)),                  
    
  "Stock Destruction" = cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                     
  From StockDestructionAbstract, StockDestructionDetail,ClaimsNote         
  Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                    
  And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID        
  And StockDestructionAbstract.DocumentDate Between @FromDate And @ToDate                     
  And ClaimsNote.Status & 1 <> 0            
  and Items.product_code like @Item            
  And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6)),    
                  
"On Hand Qty" =  cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Opening_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                       
 And VanStatementDetail.Product_Code = Items.Product_Code))
+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) FROM  
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID
And Issuedetail.SpareCode = Items.Product_Code   
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0),0)              
 end)                
   / (CASE ISNULL(Items.ReportingUnit, 0)                   
   WHEN 0 THEN                   
   1                   
   ELSE                   
   ISNULL(Items.ReportingUnit, 0)               
   END) as Decimal(18,6)),               
             
 "On Hand Saleable Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Opening_Quantity - IsNull(o1.Free_Saleable_Quantity, 0) - IsNull(o1.Damage_Opening_Quantity, 0) FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products           
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract     
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                       
 AND vanstatementdetail.purchaseprice <> 0    
 And VanStatementDetail.Product_Code = Items.Product_Code))

+Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) from   
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
And Isnull(Issuedetail.SalePrice,0) <> 0),0)
end)/ (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                         
 END) as Decimal(18,6)),                  
            
 "On Hand Free Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Free_Saleable_Quantity FROM OpeningDetails o1                      
 WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +                      
 (SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
 WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
 (VanStatementAbstract.Status & 128) = 0                      
AND vanstatementdetail.purchaseprice = 0    
 And VanStatementDetail.Product_Code = Items.Product_Code))
+ Isnull((SELECT sum(Isnull(IssuedQty,0)-Isnull(ReturnedQty,0)) from   
Issuedetail,IssueAbstract,JobcardAbstract  
where IssueAbstract.IssueID =IssueDetail.IssueID And  
IssueAbstract.JobCardId = JobcardAbstract.JobcardID   
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0  
and Isnull(jobcardAbstract.status,0) & 192 = 0   
and Isnull(jobcardAbstract.status,0) & 32 = 0  
And Isnull(Issuedetail.SalePrice,0) = 0),0)

 end) / (CASE ISNULL(Items.ReportingUnit, 0)                         
 WHEN 0 THEN                         
 1                         
 ELSE                         
 ISNULL(Items.ReportingUnit, 0)                         
 END) as Decimal(18,6)),                  
           
 "On Hand Damage Qty" = cast ((CASE when OpeningDetails.Opening_Date < @NEXT_DATE THEN                       
 ISNULL((Select o1.Damage_Opening_Quantity FROM OpeningDetails o1                
WHERE o1.Product_Code = Items.Product_Code AND                       
 o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                      
 ELSE (ISNULL((SELECT SUM(Quantity) FROM Batch_Products                       
 WHERE Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0)     
 )END) as Decimal(18,6)),    
    
--+(SELECT ISNULL(SUM(Pending), 0) FROM VanStatementDetail, VanStatementAbstract                       
-- WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND                       
-- (VanStatementAbstract.Status & 128) = 0                       
-- And VanStatementDetail.Product_Code = Items.Product_Code)) end) / (CASE ISNULL(Items.ReportingUnit, 0)                         
-- WHEN 0 THEN                         
-- 1                   
-- ELSE                         
-- ISNULL(Items.ReportingUnit, 0)                
-- END) as Decimal(18,6)),                  
           
 "On Hand Value" = cast (((CASE                   
  when (OpeningDetails.Opening_Date < @NEXT_DATE) THEN                   
  ISNULL((Select o1.Opening_Value                   
  FROM OpeningDetails o1                   
  WHERE o1.Product_Code = Items.Product_Code                   
  AND o1.Opening_Date = DATEADD(dd, 1, OpeningDetails.Opening_Date)), 0)                  
  ELSE                   
  ((SELECT ISNULL(SUM(Quantity * PurchasePrice), 0)      
  FROM Batch_Products         
  WHERE Product_Code = Items.Product_Code) +                   
  (SELECT ISNULL(SUM(Pending * PurchasePrice), 0)                   
  FROM VanStatementDetail, VanStatementAbstract                   
  WHERE VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial                   
  AND (VanStatementAbstract.Status & 128) = 0                   
  And VanStatementDetail.Product_Code = Items.Product_Code))                  

+Isnull((SELECT Sum((Isnull(IssuedQty,0) - Isnull(ReturnedQty,0)) * Isnull(Issuedetail.Purchaseprice,0)) from 
Issuedetail,IssueAbstract,JobcardAbstract
where IssueAbstract.IssueID =IssueDetail.IssueID And
IssueAbstract.JobCardId = JobcardAbstract.JobcardID 
And Issuedetail.SpareCode = Items.Product_Code
And Isnull(IssueAbstract.Status,0) & 192  = 0
and Isnull(jobcardAbstract.status,0) & 192 = 0 
and Isnull(jobcardAbstract.status,0) & 32 = 0),0)

  end  )  ) as Decimal(18,6))          
/*  /                
  (CASE ISNULL(Items.ReportingUnit, 0)                   
  WHEN 0 THEN                   
  1                   
  ELSE                   
  ISNULL(Items.ReportingUnit, 0)                   
  END))   */              
 FROM   Items, OpeningDetails , UOM
 WHERE   Items.Product_Code *= OpeningDetails.Product_Code AND                  
 OpeningDetails.Opening_Date between @FROMDATE and @TODATE                  
 AND Items.ReportingUOM *= UOM.UOM And IsNull(Items.Active,0) = 1                  
 AND Items.Product_Code = @PRODUCT_CODE                  
 group  By  OpeningDetails.Opening_Date,items.product_code,                  
 OpeningDetails.Opening_Quantity, Items.ReportingUnit , Opening_Value ,        
 OpeningDetails.Damage_Opening_Quantity, OpeningDetails.Free_Saleable_Quantity                   
end
