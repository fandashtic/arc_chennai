Create Procedure mERP_sp_ValidateUser(@UserName as nVarchar(50))
As
Begin
	If (Select Count(UserName) From Users Where UserName = @UserName COLLATE SQL_Latin1_General_Cp1_CS_AS ) >= 1
		Select 1
	Else
		Select 0

End
