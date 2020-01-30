
Create Procedure mERP_sp_GetAdminUsers
As
Select UserName From Users 
	Where GroupName = 'Administrator'
	And Active = 1

