CREATE Procedure Sp_Ser_Update_JobMaster(      
@JobID nvarchar(50),
@JobOption int,      
@LastModifiedDate datetime,      
@Active int)      
AS      
Update Jobmaster set [Free] = @JobOption,Active = @Active,
LastModifiedDate = @LastModifiedDate      
Where JobID = @JobID       
  

