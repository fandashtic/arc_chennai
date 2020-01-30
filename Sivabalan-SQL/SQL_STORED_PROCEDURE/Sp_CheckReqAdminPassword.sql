Create Procedure Sp_CheckReqAdminPassword
As
Begin
	Select IsNull(Flag,0) Flag from tbl_Merp_ConfigAbstract where ScreenCode = 'BACKDATEDTRANSACTIONALERT'
End
