CREATE procedure sp_ser_rpt_reworkdetail 
(@PersonnelID varchar(15), @FromDate datetime, @ToDate datetime)
as
Declare @JCPrefix as varchar(15) 
Select @JCPrefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'

Select 0, t.TaskID 'TaskID', t.Description 'Task Name', jt.StartDate 'Start Date', 
dbo.sp_ser_StripTimeFromDate(jt.StartTime) 'Start Time', jt.EndDate 'End Date', 
dbo.sp_ser_StripTimeFromDate(jt.EndTime) 'End Time', jt.Remarks 'Remarks', 
@JCPrefix + Cast(j.DocumentID as varchar(15)) 'JobCardID'
from JobCardAbstract j
Inner Join JobCardTaskAllocation jt On jt.JobcardId = j.JobcardID and 
jt.TaskStatus = 5 and (jt.StartDate between @FromDate and @ToDate) and 
jt.PersonnelID like @PersonnelID
Inner Join TaskMaster t on t.TaskID = jt.TaskID  
Order by jt.SerialNo

