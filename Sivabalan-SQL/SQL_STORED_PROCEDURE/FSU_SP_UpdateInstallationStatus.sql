
Create Procedure [dbo].[FSU_SP_UpdateInstallationStatus]   
(  
 @InstallId Int,  
 @Status Int  
)  
As   
BEGIN  
 If(@Status = 2 or @Status = 8 or @Status = 16 or @Status = 4)  
 Begin  
  exec FSU_sp_UpdateTblFSUSetup 1  
 End  
 if @Status = 1  
 BEGIN  
  -- reset the download failed status  
  update tblInstallationDetail set  
  Status=Status ^ 2  
  where InstallationId = @InstallID  
  And Status & 2 = 2  
  ------------  
  update tblInstallationDetail set   
  Status=Status | @Status  ,  
  ModifiedDate = getdate(),  
  ModifiedUser = host_name() + ' - ' + suser_sname(),  
  ModifiedApplication = app_name()  
  Where InstallationId = @InstallID  
 END  
 else if @Status = 2  
 BEGIN  
  -- reset the download failed status  
  update tblInstallationDetail set  
  Status=Status ^ 1  
  where InstallationId = @InstallID  
  And Status & 1 = 1  
  ------------  
  update tblInstallationDetail set   
  Status=Status | @Status  ,  
  ModifiedDate = getdate(),  
  ModifiedUser = host_name() + ' - ' + suser_sname(),  
  ModifiedApplication = app_name()  
  Where InstallationId = @InstallID  
 END  
 Else if @Status = 4  
 BEGIN  
  -- reset the installation failed - try again status   
  update tblInstallationDetail set  
  Status=Status ^ 16  
  where InstallationId = @InstallID  
  And Status & 16 = 16  
  --------------------------  
  update tblInstallationDetail set   
  Status=Status | @Status  ,  
  DateOfInstallation = getdate(),  
  ModifiedDate = getdate(),  
  ModifiedUser = host_name() + ' - ' + suser_sname(),  
  ModifiedApplication = app_name()  
  Where InstallationId = @InstallID  
 END  
 else  
 BEGIN  
  update tblInstallationDetail set   
  Status=Status | @Status  ,  
  ModifiedDate = getdate(),  
  ModifiedUser = host_name() + ' - ' + suser_sname(),  
  ModifiedApplication = app_name()  
  Where InstallationId = @InstallID  
 END  
END 