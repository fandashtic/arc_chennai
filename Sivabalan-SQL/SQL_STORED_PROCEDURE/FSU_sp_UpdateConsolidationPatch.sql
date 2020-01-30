Create Procedure dbo.[FSU_sp_UpdateConsolidationPatch] 
(
	@ClientId Int,
	@FsuId Int,
	@FileName nvarchar(100)
)
As 
Begin
insert into tblInstallationDetail 
	(ClientID,
	FSUID,
	FileName,
	Mode,
	Status)
	values
	(@ClientId,
	@FsuId,
	@FileName,
	3,
	5)
End
