CREATE Procedure sp_ser_rpt_jobDetail(@JobId nvarchar(50))
AS
Select Job_Tasks.TaskID, 'TaskID' = Job_Tasks.TaskID,TaskMaster.[Description] from job_tasks,taskmaster
where Job_tasks.JobID = @JobId
and Job_tasks.TaskId = TaskMaster.TaskID 

