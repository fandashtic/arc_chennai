
CREATE PROCEDURE sp_ser_list_warrantiedItems(@ManufacturerID int, @DATE datetime)  
AS  
Begin  
SELECT SID.SpareCode, Items.ProductName 'SpareName',   
(select Prefix from VoucherPrefix where TranID='JOBCARD') + cast(JCA.DocumentID as varchar(50)) 'JobCardID',     
JCA.JobCardDate, Items.Purchase_Price,   
(sum(SID.Quantity) - Isnull((Select sum(CD.Quantity) from ClaimsDetail CD, ClaimsNote CN where CN.ClaimID = CD.ClaimID and CN.Status & 192 <> 192 and CD.JobcardID = SIA.JobcardID and CD.Product_Code = SID.SpareCode), 0)) as ClaimableQuantity,     
Case SIA.ServiceType     
 When 1 Then 'Paid on Charge'    
 When 2 Then 'Warranty Service'    
 When 3 Then 'Estimation Required'    
End    
As ServiceType    
FROM ServiceInvoiceAbstract SIA    
INNER JOIN ServiceInvoiceDetail SID ON SIA.ServiceInvoiceID = SID.ServiceInvoiceID    
INNER JOIN JobCardAbstract JCA ON SIA.JobcardID = JCA.JobCardID    
INNER JOIN Items ON SID.SpareCode = Items.Product_Code and Items.ManufacturerID = @ManufacturerID  
LEFT OUTER JOIN (Select BP.Batch_Code, BP.Product_Code  
from Batch_Products BP  
INNER JOIN GRNAbstract GRN ON GRN.GRNID = BP.GRN_ID) BATCH   
ON SID.SpareCode = BATCH.Product_Code  
   AND SID.Batch_Code = BATCH.Batch_Code  
WHERE (SID.Chargeable = 0 OR SID.Warranty = 1) --Items may be non chargeable or Warranttied    
AND (SIA.ServiceType = 2 OR SIA.ServiceType = 3) --Warranty Service (2) And Estimation Requied (3) will be allowed to Claim    
AND (SIA.Status & 128) <> 128    
AND (SIA.Status & 64) <> 64    
AND (IsNull(SID.Batch_Code,0) = 0 OR  IsNull(BATCH.Batch_Code,0) <> 0)  
GROUP BY SID.SpareCode, Items.ProductName, SIA.JobCardID, JCA.DocumentID, JCA.JobCardDate, Items.Purchase_Price, SID.Quantity, SIA.ServiceType     
Having (sum(SID.Quantity) - Isnull((Select sum(CD.Quantity) from ClaimsDetail CD, ClaimsNote CN where CN.ClaimID = CD.ClaimID and CN.Status & 192 <> 192 and CD.JobcardID = SIA.JobcardID and CD.Product_Code = SID.SpareCode), 0)) > 0    
ORDER BY JCA.DocumentID  
End  


