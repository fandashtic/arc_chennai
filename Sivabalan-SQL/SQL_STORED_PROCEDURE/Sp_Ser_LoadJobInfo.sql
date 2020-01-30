CREATE Procedure Sp_Ser_LoadJobInfo(@JobId nvarchar(50))  
as  
select jobid,taskmaster.taskid,[Description] from job_tasks,taskmaster 
where job_tasks.jobid = @jobId  
and taskmaster.taskid = job_tasks.taskid  

