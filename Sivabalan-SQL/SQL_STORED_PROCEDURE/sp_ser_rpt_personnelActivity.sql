CREATE procedure sp_ser_rpt_personnelActivity(@personnelName nvarchar(50),@FromDate datetime,@Todate datetime)              
AS              
select 'PersonnelID' =jobcardtaskallocation.PersonnelID,      
'PersonnelID' =jobcardtaskallocation.PersonnelID,'Personnel Name ' = personnelname,               
'Type' = [Description],              
'Max Task Limit' = Noofjobs,              
'Task Done' = count(Taskid)              
from jobcardtaskallocation,personnelmaster,generalmaster              
where --(IsNull(jobcardabstract.Status, 0) & 32) <> 0                        
IsNull(jobcardtaskallocation.taskstatus,0) = 2
-- and jobcardtaskallocation.jobcardid = jobcardabstract.jobcardid              
AND PersonnelMaster.PersonnelName like @PersonnelName             
and jobcardtaskallocation.personnelid = personnelmaster.personnelid              
and personnelmaster.personneltype = generalmaster.code              
and (jobcardtaskallocation.startdate) between @FromDate and @Todate              
group by jobcardtaskallocation.PersonnelID, personnelmaster.PersonnelName,              
personnelmaster.NoofJobs,generalmaster.[Description]              


