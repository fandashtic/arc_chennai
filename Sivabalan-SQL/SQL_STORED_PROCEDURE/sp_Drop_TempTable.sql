
Create Procedure sp_Drop_TempTable(@netaddr as nVarchar(100))
As
Begin
	Declare @Str as nVarchar(500)
	Set @Str='Drop Table ##' + @netaddr
	Exec sp_executesql @Str
End
