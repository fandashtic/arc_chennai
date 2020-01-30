Create Procedure mERP_sp_checkDefault_DSTypeValue(@DsType as nVarchar(500))
As
Begin
	if  Exists(Select * From DSType_Master Where DSTypeValue = @DsType And DSTypeCtlPos = 1 )
		Select 1
	Else
		Select 0
End

