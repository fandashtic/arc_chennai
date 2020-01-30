Create Procedure dbo.[FSU_sp_InsertManualUpdate] 
(
	@ClientId Int,
	@FsuId Int,
	@FileName nvarchar(100),
	@TargetTool int,
	@LocalPath nvarchar(1000)
)
As 
Begin
insert into tblInstallationDetail 
	(ClientID,
	FSUID,
	FileName,
	TargetTool,
	LocalPath,
	SeverityType,
	InstallationDate,
	Mode,
	Status)
	values
	(@ClientId,
	@FsuId,
	@FileName,
	@TargetTool,
	@LocalPath,
	1,
	Getdate(),
	1,
	1)
End
