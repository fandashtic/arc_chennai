Create Procedure mERP_sp_ValidateLogin(@UserName nVarchar(255))
As
	Select IsNull(Password, '') From Users 
		Where UserName = @UserName
		And Active = 1
