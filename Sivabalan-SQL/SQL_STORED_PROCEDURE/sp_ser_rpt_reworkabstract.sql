CREATE procedure sp_ser_rpt_reworkabstract 
(@FromDate datetime, @ToDate datetime)
as

Select p.PersonnelID, p.PersonnelID, p.PersonnelName 'Personnel Name', 
Sum((Case IsNull(t.SerialNo, -1) When -1 then 0 else 1 end)) 'No of Reworks'  
from JobCardAbstract j
Inner Join JobCardTaskAllocation t On t.JobcardId = j.JobcardID and 
t.TaskStatus = 5 and (t.StartDate between @FromDate and @ToDate)
Inner Join PersonnelMaster p on p.PersonnelID = t.PersonnelID 
Group by p.PersonnelID, p.PersonnelName

