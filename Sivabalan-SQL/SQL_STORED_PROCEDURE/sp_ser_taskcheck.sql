CREATE procedure sp_ser_taskcheck(@PersonnelName nvarchar(50),@JobcardID int)    
as    
Declare @NoOfJobs as int     
Select @NoOfJobs = personnelmaster.Noofjobs     
from personnelmaster where personnelmaster.personnelname = @PersonnelName    
select count(*)as NoofTask,  @NoOfJobs 'NoOfJobs'    
from jobcardtaskallocation,personnelmaster     
Where jobcardtaskallocation.personnelid = personnelmaster.personnelid    
and personnelmaster.personnelname = @PersonnelName    
and IsNull(TaskStatus,0) = 1    
and jobcardtaskallocation.jobcardid <> @JobcardID  

