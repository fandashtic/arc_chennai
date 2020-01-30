

Create Procedure spr_ser_TransactionTimingDetail(@JobCardID int)
AS

Begin

Declare @AcknowledgementDate DateTime

--to get the Acknowledgement Date for the Jobcard....
Select @AcknowledgementDate = AcknowledgementDate from JCAcknowledgementAbstract
Where AcknowledgementID = (Select AcknowledgementID from JobCardAbstract where JobCardID = @JobCardID)



Select 1, 'Job Acknowledgement' as 'Transaction', CreationDate as 'System Date',
AcknowledgementDate as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(AcknowledgementDate),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, AcknowledgementDate),'') as 'Time Elapsed'
from JCAcknowledgementAbstract where AcknowledgementID = (Select AcknowledgementID from JobCardAbstract where JobCardID = @JobCardID)

Union

Select 2, 'JobCard' as 'Transaction', CreationDate as 'System Date',
JobCardDate as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(JobCardDate),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, JobCardDate),'') as 'Time Elapsed'
from JobCardAbstract where JobCardID = @JobCardID

Union

Select 3, 'Estimate Intimation' as 'Transaction', JobCardIntimation.CreationDate as 'System Date',
IntimationDate as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(IntimationDate),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, IntimationDate),'') as 'Time Elapsed'
from JobCardAbstract LEFT OUTER JOIN JobCardIntimation ON JobCardIntimation.JobCardID = JobCardAbstract.JobCardID
Where JobCardAbstract.JobCardID = @JobCardID

Union

Select 4, 'Estimate Approval' as 'Transaction', JobCardApproval.CreationDate as 'System Date',
ApprovedDate as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(ApprovedDate),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, ApprovedDate),'') as 'Time Elapsed'
from JobCardAbstract LEFT OUTER JOIN JobCardApproval ON JobCardApproval.JobCardID = JobCardAbstract.JobCardID
where JobCardAbstract.JobCardID = @JobCardID

Union

Select 5, 'Issue Spare' as 'Transaction', max(CreationDate) as 'System Date',
max(IssueDate) as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(max(IssueDate)),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, max(IssueDate)),'') as 'Time Elapsed'
from IssueAbstract where JobCardID = @JobCardID and (Isnull(Status, 0) & 192) <> 192

Union
Select 6, 'Task Allocation' as 'Transaction', min(CreationTime) as 'System Date',
min(LastUpdatedTime) as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(min(LastUpdatedTime)),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, min(LastUpdatedTime)),'') as 'Time Elapsed'
from JobCardTaskAllocation where JobCardID = @JobCardID and Isnull(TaskStatus, 0) <> 0

Union

Select 7, 'Close task' as 'Transaction', max(LastUpdatedTime) as 'System Date',
max(EndTime) as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(max(EndTime)),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, max(EndTime)),'') as 'Time Elapsed'
from JobCardTaskAllocation where JobCardID = @JobCardID and Isnull(TaskStatus, 0) = 2

Union

Select 8, 'Billing' as 'Transaction', ServiceInvoiceAbstract.CreationTime as 'System Date',
ServiceInvoiceDate as 'Forum Date', isnull(dbo.sp_ser_StripTimeFromDate(ServiceInvoiceDate),'') as 'Time',
isnull(dbo.sp_ser_StripTimeDifference(@AcknowledgementDate, ServiceInvoiceDate),'') as 'Time Elapsed'
from JobCardAbstract LEFT OUTER JOIN ServiceInvoiceAbstract ON ServiceInvoiceAbstract.JobCardID = JobCardAbstract.JobCardID
where JobCardAbstract.JobCardID = @JobCardID


Order by 1

End

SET QUOTED_IDENTIFIER OFF
