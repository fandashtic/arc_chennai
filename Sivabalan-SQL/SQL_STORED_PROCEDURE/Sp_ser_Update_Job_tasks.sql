CREATE Procedure Sp_ser_Update_Job_tasks(    
@JobID nvarchar(50),      
@TaskID nvarchar(50)      
)      
AS     
If Not Exists(select * from job_Tasks where jobid = @jobid
and Taskid = @taskid)
Begin
Insert into Job_tasks      
(JObID,TaskID)      
values (@jobId,@TaskID)     
End

