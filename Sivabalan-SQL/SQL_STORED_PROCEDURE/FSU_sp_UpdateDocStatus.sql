CREATE  Procedure FSU_sp_UpdateDocStatus(@ReleaseID int,@Status int)  
as      
Update  tblReleaseDetail set Status = Status | @Status ,ModifiedDate=getdate(),ModifiedApplication = app_name() , ModifiedUser=host_name() + ' - ' + suser_sname() where ReleaseID=@ReleaseID  
