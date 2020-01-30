CREATE procedure sp_ser_taskbounceCase  
(@TaskID nvarchar(50),@ProductCode nvarchar(15), @ItemSpec1 as nvarchar(50),   
@CurrentJobCarddate datetime)  
as  
Declare @IsBounce as tinyint /* 0 New 1 Bounce case */  
Declare @TaskWarrantyDays as Integer  
Declare @datefrom as datetime  
  
Select @TaskWarrantyDays = WarrantyDays from TaskMaster where TaskID = @TaskID  
Set @datefrom = DateAdd(dd, (IsNull(@TaskWarrantyDays, 0) * -1), @CurrentJobCarddate)   

Declare @Prefix as varchar(15)  
Declare @JCDocumentID as int 
Declare @JobcardDate as dateTime 
Declare @JobcardID as int 

Select @IsBounce = Count(*), @JobcardID = IsNull(j.JobcardID,0)
from JobCardAbstract j   
Inner Join JobCardTaskAllocation a on a.JobCardID = j.JobCardID   
Where a.TaskStatus = 2 and a.TaskId = @TaskId and IsNull(j.ServiceInvoiceID,0) > 0 and   
 a.Product_Code = @ProductCode and a.Product_specification1 = @ItemSpec1 and   
 (Datediff(dd, j.JobCardDate, @CurrentJobCarddate) <= @TaskWarrantyDays) and   
 (j.JobCardDate between @datefrom and @CurrentJobCarddate)   
Group by j.JobcardID
  
If IsNull(@IsBounce,0) > 1 Set @IsBounce = @IsBounce / @IsBounce   

select  @Prefix = Prefix from VoucherPrefix where [TranID]='JOBCARD'
Select @JCDocumentID = DocumentID, @JobcardDate= Jobcarddate 
from JobcardAbstract Where JobcardID = @JobcardID 

Select IsNull(@IsBounce, 0) 'Bounce', 
(IsNull(@Prefix,'') +  Cast(@JCDocumentID as varchar(15))) JCDocNo, 
@JobcardDate JcDate, IsNUll(@JobcardID,0) 'JobCardID'
/*   
 Procedure returns 0 or 1 to identify the bounce case   
 Jobcard date taken for condition (18.02.05)   
 Bounce case jobcard info , included to avail in display (19.02.05)
*/ 
