
Create Procedure dbo.FSU_sp_GetFSUupdates(@ClientID Int)
As 

	Select count(*) As 'NoREC' from dbo.tblInstallationDetail IND 
	where
    ((IND.Status & 1 = 1 or IND.Status & 32 = 32)
	AND (IND.Status & 4 = 0 AND IND.Status & 8 = 0))
	AND IND.TargetTool = 2 
	AND InstallationDate <= getdate()
	AND ClientID = @ClientID

	Select IND.InstallationId, IsNull(IND.ReleaseID,0), IsNull(IND.FSUID,0), IND.DateofInstallation, IND.FileName, 
		IsNull(IND.TargetTool,0), IND.LocalPath, IsNull(IND.MaxSkip,0), IsNull(IND.SkipCount,0),
        Case 
            When IND.SkipCount = IND.MaxSkip
            then 1 
            else IsNull(IND.SeverityType,1)
        end As 'SeverityType',
        IND.Mode
    from dbo.tblInstallationDetail IND 
	where
    ((IND.Status & 1 = 1 or IND.Status & 32 = 32)
	AND IND.Status & 4 = 0 AND IND.Status & 8 = 0)
	AND IND.TargetTool = 2 
	AND InstallationDate <= getdate()
	AND ClientID = @ClientID

