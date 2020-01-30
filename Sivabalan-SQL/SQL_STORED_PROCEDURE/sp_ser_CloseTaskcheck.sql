CREATE procedure sp_ser_CloseTaskcheck(@PersonnelName nvarchar(50), @JobcardID int )        
as        
-- @JobcardID to skip the selected Jobcard
Declare @NoOfJobs as int
Select @NoOfJobs = personnelmaster.Noofjobs from personnelmaster 
where personnelmaster.personnelname = @PersonnelName

select count(*) 'NoofTask',  @NoOfJobs 'NoOfJobs'
from Jobcardtaskallocation 
Inner Join Personnelmaster On Jobcardtaskallocation.personnelid = Personnelmaster.personnelid
Where Jobcardtaskallocation.JobCardID <> @JobcardID
and personnelmaster.personnelname = @PersonnelName
and IsNull(TaskStatus,0) = 1




