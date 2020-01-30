Create Procedure [dbo].[FSU_sp_UpdateSkipCount] (@nInstallId Int)
As 
	Update dbo.tblInstallationDetail set SkipCount = isnull(SkipCount,0) + 1 Where InstallationId = @nInstallId
