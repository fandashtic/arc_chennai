Create Procedure dbo.[FSU_sp_InserttblInstallationDetail]
(
	@InstallationID int
)	
As
begin
insert into tblInstallationDetail
(
	ClientID ,ReleaseID ,SeverityType ,FSUID ,FileName ,Mode ,Targettool ,MaxSkip ,InstallationDate,Status)
	select	CM.ClientID,IND.ReleaseID,SeverityType,FSUID,FileName,Mode,Targettool ,MaxSkip ,InstallationDate,0
	from tblInstallationDetail IND
	inner join tblReleaseDetail RD on RD.ReleaseID = IND.ReleaseID
	left outer join tblClientMaster CM on CM.ClientID <> IND.ClientID 
	where IND.InstallationID = @InstallationID
	AND CM.IsServer <> 1

end
