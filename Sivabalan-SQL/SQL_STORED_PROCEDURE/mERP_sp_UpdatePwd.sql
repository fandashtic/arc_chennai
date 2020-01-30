
Create Procedure mERP_sp_UpdatePwd(@UserName nVarchar(255), @Password nVarchar(255))
As
	Update Users Set Password = @Password Where UserName = @UserName


