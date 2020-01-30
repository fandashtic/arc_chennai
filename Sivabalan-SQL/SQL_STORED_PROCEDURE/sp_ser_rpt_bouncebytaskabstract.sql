CREATE procedure sp_ser_rpt_bouncebytaskabstract 
(@FromDate datetime, @ToDate datetime)
as

Select t.TaskID, t.TaskID, t.Description 'Task Name', Sum(IsNull(jt.TaskType,0)) 'No of Bounce Case' 
from JobCardAbstract a 
Inner Join JobCardTaskAllocation jt On a.JobCardID = jt.JobCardID and jt.Type = 2 and 
IsNull(jt.TaskStatus, 0) = 2  and (IsNull(jt.TaskType,0) = 1) and 
(IsNull(a.Status, 0) & 192 <> 192) and (a.JobcardDate between @FromDate and @ToDate)
Inner Join TaskMaster t On t.TaskId = jt.TaskID 
Group By t.TaskID, t.Description

