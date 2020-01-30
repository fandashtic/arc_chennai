Create Procedure mERP_Sp_EnableGSTFlag
As
Begin
IF Not Exists(Select 'x' From tbl_mERP_RecConfigAbstract Where MenuName = 'GSTaxEnabled')
	Insert Into tbl_mERP_RecConfigAbstract (MenuName,Flag,Status) Values ('GSTaxEnabled',1,3)
End
