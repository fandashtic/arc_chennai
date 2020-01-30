CREATE Procedure FSU_sp_UpdateDependentFSUID
(
@InstallationID int,
@FSUID int )
As                
begin
	Insert Into tblDependentDetail (InstallationID,DependentFSUID) values(@InstallationID,@FSUID)
END
