CREATE Procedure Sp_Ser_Insert_Job_tasks(    
@JobID nvarchar(50),    
@TaskID nvarchar(50)    
)    
AS    
Insert into Job_tasks    
(JObID,TaskID)    
values (@jobId,@TaskID)    



