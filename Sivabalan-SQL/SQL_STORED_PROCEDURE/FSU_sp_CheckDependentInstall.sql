
Create Procedure dbo.[FSU_sp_CheckDependentInstall] 
(
    @nClientId Int,
    @nFsuId Int
)
As 
Begin
	Select Count(*) from dbo.tblInstallationDetail 
	where ClientId = @nClientId And FSUID = @nFSUId and  Status & 4 = 4 
End
