Create Procedure mERP_sp_NonQPSDC_ResetFSULogDate(@ProcessDate DateTime)
As
Begin
Declare @FirstInstalledID int
Select @FirstInstalledID = Min(InstallationId) from tblinstallationdetail Where FSUID = 3677 and (Status & 4) = 4

/*To update the FSU modifled date with respect to the NonQPS Process completion*/
Update tblinstallationdetail Set ModifiedDate = @ProcessDate Where InstallationId = @FirstInstalledID
/*To update the FSU Creation date with respect to the NonQPS Process completion*/
Update tbl_errorLog Set CreationDate = @ProcessDate Where InstallationId = @FirstInstalledID
insert into tbl_errorLog (InstallationID,ErrorMessage,CreationDate) values (@FirstInstalledID,'The NonQPS RFA data posting process completed successfully',@ProcessDate)
End
