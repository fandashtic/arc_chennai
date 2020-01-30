Create Procedure mERP_sp_Check_MarginImplemented
As
Begin
	If Not Exists(Select * From SysObjects Where Name = 'tbl_mERP_MarginDetail' And Xtype = 'u')
		Select 0
	Else If ((Select Count(*) From tbl_mERP_MarginDetail) = 0 )
		Select 1
	Else 
		Select 2

End	
