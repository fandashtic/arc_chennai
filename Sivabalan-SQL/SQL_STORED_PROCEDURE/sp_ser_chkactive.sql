CREATE Procedure sp_ser_chkactive(@TaskId nvarchar(50))
As
select jobmaster.active
from taskmaster,job_tasks,jobmaster 
where 
job_tasks.taskid = taskmaster.taskid 
and job_tasks.jobid = jobmaster.jobid 
and jobmaster.active = 1
and taskmaster.taskid = @Taskid



