
Create Procedure dbo.[FSU_sp_GetmERPupdates]  
(@ClientID int  
)  
As   
BEGIN
Select Count(*)  
    from dbo.tblInstallationDetail IND, tbl_merp_configabstract Config  
 --inner join dbo.tblReleaseDetail RD on IND.ReleaseID = RD.ReleaseId  
 WHERE
	Config.ScreenCode='FSUCutoff'
	And IND.FSUID >= Cast(Description as int)   
    And ((IND.Status & 1 = 1 or IND.Status & 32 = 32)  
 AND IND.Status & 4 = 0 AND IND.Status & 8 = 0)  
 AND IND.TargetTool = 1   
 AND IND.InstallationDate <= getdate()  
 AND IND.ClientID = @ClientID  
  
 Select IND.InstallationId, IND.ReleaseID, IND.FSUID, IND.DateofInstallation, IND.FileName,   
  IND.TargetTool, IND.LocalPath, IND.MaxSkip, IND.SkipCount,IND.MODE,  
        Case   
            When IND.SkipCount >= isnull(IND.MaxSkip,0) AND IND.SeverityType = 0  
            then 1   
            else IND.SeverityType  
        end As 'SeverityType'  
    from dbo.tblInstallationDetail IND ,tbl_merp_configabstract Config   
 --inner join dbo.tblReleaseDetail RD on IND.ReleaseID = RD.ReleaseId  
 WHERE  
	Config.ScreenCode='FSUCutoff'
	And IND.FSUID >= Cast(Description as int)   
    And ((IND.Status & 1 = 1 or IND.Status & 32 = 32)  
 AND IND.Status & 4 = 0 AND IND.Status & 8 = 0)  
 AND IND.TargetTool = 1   
 AND IND.InstallationDate <= getdate()  
 AND IND.ClientID = @ClientID  
 Order by IND.FSUID  
END
