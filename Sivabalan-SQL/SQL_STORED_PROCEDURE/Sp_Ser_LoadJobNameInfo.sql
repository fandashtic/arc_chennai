Create Procedure Sp_Ser_LoadJobNameInfo(@Jobid nvarchar(50),@Jobname nvarchar(255))
as
select jobid,taskmaster.taskid,[Description] from job_tasks,taskmaster 
where job_tasks.jobid = @jobId  
and taskmaster.taskid = job_tasks.taskid  


