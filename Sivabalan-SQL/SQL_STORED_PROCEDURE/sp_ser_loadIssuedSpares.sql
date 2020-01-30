CREATE procedure sp_ser_loadIssuedSpares   
(@JobCardID as int, @Product_Code as nvarchar(15), @Product_Specification1 as nvarchar(50))   
as  
Declare @EstmationID as int   
Select @EstmationID = EstimationID from JobCardAbstract where JobCardID = @JobCardID   

Select IssueDetail.SerialNo,   
IssueDetail.IssueID,   
IssueAbstract.IssueDate,  
IssueDetail.SpareCode,   
Items.ProductName,   
IssueDetail.Batch_Number,   
UOM.Description,   
IssueDetail.DateofSale,   
IsNull(IssueDetail.Warranty,2) Warranty ,   
IssueDetail.WarrantyNo,   
IssueDetail.SalePrice,   
IsNUll(est.UOMPrice, 0) EstPrice,   
(isNull(IssueDetail.IssuedQty,0) - IsNull(IssueDetail.ReturnedQty,0)) 
/ (Case IssueDetail.UOM when UOM1 then isNull(UOM1_Conversion,1) when UOM2 then isNull(UOM2_Conversion,1) else 1 end ) UOMQty,   
  
IssueDetail.SaleTax_Percentage,  
IssueDetail.TaxSuffered_Percentage,   
IssueDetail.Batch_Code,   
IssueDetail.UOM,   
"UomConverstion" = (Case IssueDetail.UOM when UOM1 then UOM1_Conversion 
			when UOM2 then UOM2_Conversion else 1 end ),    
(IssueDetail.IssuedQty - IsNull(IssueDetail.ReturnedQty,0)) IssuedQty,  
IssueDetail.ReturnedQty,  
IssueDetail.UOMPrice,  
IssueDetail.TaxID,  
Items.SaleID, 
IssueAbstract.DocumentID, 
IssueDetail.TaxID,
Isnull(JobMaster.JobName,'') JobName, IsNull(JobFree, 0) JobFree,
IsNull(JobCardSpares.JobID, '') 'JobID', IsNull(TaskID,'') TaskID, 
isnull(Claim_price, 0) 'Claimprice', IsNull(Vat_Exists,0) 'Vat_Exists', 
IsNull(Items.CollectTaxSuffered, 0) 'CollectTaxSuffered'
from IssueDetail   
Inner Join IssueAbstract On IssueDetail.IssueId = IssueAbstract.IssueId 
	and ((IsNull(IssueAbstract.Status, 0) & 192) = 0)    
Inner Join Items On Items.Product_Code = IssueDetail.SpareCode  
Inner Join UOM on IssueDetail.UOM = UOM.UOM   
Left outer Join JobCardSpares On JobCardSpares.SerialNo = ReferenceId 
left Outer Join JobMaster On JobMaster.JobID = JobCardSpares.JobID
Left Outer Join    
(Select   
e.SerialNo, e.EstimationID, e.Product_Code, e.Product_Specification1, e.SpareCode, e.UOMPrice, 
e.uom   
from EstimationDetail e where e.SpareCode <> '' and e.EstimationID = @EstmationID and   
e.Product_Code = @Product_Code and e.Product_Specification1 = @Product_Specification1 and 
e.SerialNo = (Select top 1 t.SerialNo from EstimationDetail t where   
t.EstimationID = e.EstimationID and t.Product_Code = e.Product_Code and   
t.Product_Specification1 = e.Product_Specification1 and t.SpareCode = e.SpareCode and   
t.SpareCode <> '' and t.UOM = e.UOM Order by t.SerialNo)) est   
On IssueDetail.Product_Code = est.Product_Code and   
	IssueDetail.Product_Specification1 = est.Product_Specification1 and   
	IssueDetail.SpareCode = est.SpareCode and est.UOM = IssueDetail.UOM 
Where  
	IssueAbstract.JobCardId = @JobCardId and   
	IssueDetail.Product_Code = @Product_Code and   
	IssueDetail.Product_Specification1 = @Product_Specification1 and 
	(isNull(IssueDetail.IssuedQty,0) - IsNull(IssueDetail.ReturnedQty,0)) > 0
Order by IssueDetail.SerialNo  




