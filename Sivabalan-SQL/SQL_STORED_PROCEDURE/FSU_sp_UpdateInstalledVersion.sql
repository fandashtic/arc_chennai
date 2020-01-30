
Create Procedure [dbo].[FSU_sp_UpdateInstalledVersion]
(
    @nInstallId Int,
	@sFileName nVarchar(250),
	@sVersionNo nVarchar(50),
	@sRepVerNo nVarchar(50)
)
As 
Begin

	Insert into dbo.tblInstalledVersions 
	(InstallationId, FileName, VersionNo, ReplacingVersionNo)
	values (@nInstallId, @sFileName, @sVersionNo, @sRepVerNo)

End
