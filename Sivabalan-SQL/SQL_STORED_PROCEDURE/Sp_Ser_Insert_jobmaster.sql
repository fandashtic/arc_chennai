CREATE Procedure Sp_Ser_Insert_jobmaster(    
@JobID nvarchar(50),    
@JobName nvarchar(255),    
@JobOption int,
@LastModifedDate datetime)    
As    
Insert into Jobmaster     
(JobId,JobName,[Free],LastModifiedDate,Active) Values (@JobID,@JobName,@JobOption,getdate(),1) 
