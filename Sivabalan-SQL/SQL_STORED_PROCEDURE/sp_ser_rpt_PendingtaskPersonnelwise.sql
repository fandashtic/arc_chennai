CREATE procedure sp_ser_rpt_PendingtaskPersonnelwise(@personnelName nvarchar(50),@FromDate datetime,@Todate datetime)                  
AS                  
Select 'Personnel ID' = jobcardtaskallocation.PersonnelID,          
'Personnel ID' = jobcardtaskallocation.PersonnelID, 
'Personnel Name ' = personnelname,                   
'No of Task Pending' = count(Taskstatus)                  
from Jobcardtaskallocation, personnelmaster, JobcardAbstract  
where Jobcardtaskallocation.JobCardID = JobcardAbstract.JobCardID
and personnelmaster.personnelid = Jobcardtaskallocation.personnelid          
and isnull(taskstatus,0) = 1
and PersonnelMaster.PersonnelName like @PersonnelName                 
and (JobcardAbstract.JobCardDate) between @FromDate and @Todate                  
group by Jobcardtaskallocation.PersonnelID, personnelmaster.PersonnelName                  


