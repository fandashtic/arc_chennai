Create Procedure mERP_Sp_UpdateStatus_AccpChannlAbstract (@ID int)
As
Begin 
Update tbl_mERP_RecdChannlAbstract Set status=32 where ID =  @ID
End 
