Create Procedure mERP_Sp_UpdateStatus_AccpMasChangeAbstract (@ID int)
As
Begin 
Update tbl_mERP_RecdMstChangeAbstract Set status=32 where ID =  @ID
End 
SET QUOTED_IDENTIFIER OFF
