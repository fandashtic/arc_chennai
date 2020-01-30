Create Procedure mERP_Sp_UpdateStatus_AccpDivisionAbstract (@ID int)
As
Begin 
Update tbl_mERP_RecdCatAbstract Set status=32 where ID =  @ID
End 
