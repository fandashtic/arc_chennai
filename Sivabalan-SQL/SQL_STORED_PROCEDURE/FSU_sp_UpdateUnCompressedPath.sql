Create Procedure [dbo].[FSU_sp_UpdateUnCompressedPath] (
@nInstallId Int,
@szUnCompressedPath nvarchar(500)
)
As 
	Update dbo.tblInstallationDetail set ExtractedFilePath = @szUnCompressedPath Where InstallationId = @nInstallId
