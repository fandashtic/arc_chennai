
Create Procedure sp_Clear_TempTable(@netaddr as nVarchar(100))
As
Begin
	Declare @Str as nVarchar(500)
	Set @Str='Truncate Table ##' + @netaddr
	Exec sp_executesql @Str
End
