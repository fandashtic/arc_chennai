CREATE  Procedure FSU_sp_UpdateSavedPath(@ReleaseID int,@TargetPath varchar(500))  
as      
Update  tblDocumentDetail set SavedLocalPath=@TargetPath ,ModifiedDate=getdate(),ModifiedApplication = app_name() , ModifiedUser=host_name() + ' - ' + suser_sname() where ReleaseID=@ReleaseID  
