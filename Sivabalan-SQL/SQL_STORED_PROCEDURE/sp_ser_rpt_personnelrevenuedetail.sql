CREATE procedure sp_ser_rpt_personnelrevenuedetail 
(@PersonnelID varchar(15), @FromDate datetime, @ToDate datetime)
as
Declare @JCPrefix as varchar(15)
Declare @SIPrefix as varchar(15)
 
Select @SIPrefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'
Select @JCPrefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'

Select 0, t.TaskID, m.Description 'Task Name', d.Price 'Rate', 
t.StartDate 'Start Date', dbo.sp_ser_StripTimeFromDate(t.StartTime) 'Start Time', 
t.EndDate 'End Date', dbo.sp_ser_StripTimeFromDate(t.EndTime) 'End Time', 
@JCPrefix + Cast(j.DocumentID as varchar(15)) 'JobCardID', 
@SIPrefix + Cast(a.DocumentID as varchar(15)) 'ServiceInvoiceID'
from JobCardtaskAllocation t --On p.PersonnelID = t.PersonnelID
Inner Join TaskMaster m On t.TaskId = m.TaskID 
Inner Join JobcardAbstract j On j.JobcardID = t.JobcardID 
Inner Join ServiceInvoiceAbstract a On a.JobCardID = j.JobcardID 
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID and 
d.Product_Code = t.Product_Code and d.Product_Specification1 = t.Product_Specification1 and 
t.TaskID = d.TaskID 
Where t.PersonnelID = @PersonnelID and IsNull(d.Price,0) > 0 and  
t.TaskStatus = 2 and d.Type = 2 and IsNull(d.Sparecode,'') = '' and 
((IsNull(a.status,0) & 192) <> 192) and ((IsNull(j.status,0) & 192) <> 192) and 
(a.ServiceInvoiceDate between @fromdate and @todate)

