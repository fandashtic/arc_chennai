Create Procedure [dbo].[FSU_sp_UpdateThinClientDownlodedPath] (
@nInstallId Int,
@szDownloadedPath nvarchar(500)
)
As 
	Update dbo.tblInstallationDetail set LocalPath = @szDownloadedPath Where InstallationId = @nInstallId
