CREATE Procedure FSU_sp_getCOMVersionList_ITC(@Recoverable int=1,@IsServer int = 1)  
AS  
if @IsServer = 1
	select CV.ComponentName,CV.FileType, CV.Version , isnull(ID.FileName,'Build') as "updateName"
	from  ComVersion  CV 
	left join tblInstallationDetail ID on CV.Installation_ID = ID.InstallationID
	where  Recoverable = @Recoverable  
	AND (Applicable = 1 or Applicable = 2)
else
	select CV.ComponentName,CV.FileType, CV.Version , isnull(ID.FileName,'Build') as "updateName"
	from  ComVersion  CV 
	left join tblInstallationDetail ID on CV.Installation_ID = ID.InstallationID
	where  Recoverable = @Recoverable  
	AND Applicable = 2
