
CREATE PROCEDURE sp_ser_list_warrantiedTasks(@ManufacturerID int, @DATE datetime)
AS
Begin
SELECT SID.Product_Code, Items.ProductName, SID.Product_Specification1,
SID.TaskID, TaskMaster.Description 'TaskName',
(select Prefix from VoucherPrefix where TranID='JOBCARD') + cast(JCA.DocumentID as varchar(50)) 'JobCardID', 
JCA.JobCardDate, JCD.ActualCharge,

Case SIA.ServiceType   
 When 1 Then 'Paid on Charge'  
 When 2 Then 'Warranty Service'  
 When 3 Then 'Estimation Required'  
End  
As ServiceType  
FROM ServiceInvoiceAbstract SIA  
INNER JOIN ServiceInvoiceDetail SID ON SIA.ServiceInvoiceID = SID.ServiceInvoiceID  
INNER JOIN JobCardAbstract JCA ON SIA.JobcardID = JCA.JobCardID  
INNER JOIN JobCardDetail JCD ON SIA.JobcardID = JCD.JobCardID and SID.Product_Code = JCD.Product_Code and SID.TaskID = JCD.TaskID and SID.Product_Specification1 = JCD.Product_Specification1
INNER JOIN Items ON SID.Product_Code = Items.Product_Code and Items.ManufacturerID = @ManufacturerID
INNER JOIN TaskMaster ON SID.TaskID = TaskMaster.TaskID
LEFT OUTER JOIN (Select BP.Batch_Code, BP.Product_Code
from Batch_Products BP
INNER JOIN GRNAbstract GRN ON GRN.GRNID = BP.GRN_ID) BATCH 
ON SID.Product_Code = BATCH.Product_Code
   AND SID.Batch_Code = BATCH.Batch_Code
WHERE (SID.Chargeable = 0 OR SID.Warranty = 1) --Items may be non chargeable or Warranttied  
AND Isnull(SID.TaskID, '') <> '' and Isnull(SID.SpareCode, '') = '' -- to select the tasks...
AND (JCD.Chargeable = 0 OR JCD.Warranty = 1) --Items may be non chargeable or Warranttied  
AND (Isnull(JCD.TaskID, '') <> '' and Isnull(JCD.SpareCode, '') = '') -- to select the tasks...
AND (SIA.ServiceType = 2 OR SIA.ServiceType = 3) --Warranty Service (2) And Estimation Requied (3) will be allowed to Claim  
AND (SIA.Status & 128) <> 128  
AND (SIA.Status & 64) <> 64  
AND (IsNull(SID.Batch_Code,0) = 0 OR  IsNull(BATCH.Batch_Code,0) <> 0)
--to check whether the task for the jobcard is already Claimed or not...
AND (Select Count(*) from ClaimsDetail CD, ClaimsNote CN where CN.ClaimID = CD.ClaimID AND CN.Status & 192 <> 192 AND SIA.JobCardId = CD.JobCardId AND SID.Product_Code = CD.Product_Code AND SID.TaskID = CD.TaskID) = 0
GROUP BY SID.Product_Code, SID.Product_Specification1, Items.ProductName, SID.TaskID, TaskMaster.Description, JCA.DocumentID, JCA.JobCardDate, JCD.ActualCharge, SIA.ServiceType 

ORDER BY JCA.DocumentID
End

