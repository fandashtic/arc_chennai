Create Procedure mERP_Sp_updateStatus_Rejectabstract ( @ID int, @ScrCode nVarchar(255), @Errmessage nVarchar(255))
As
Begin
	Update tbl_mERP_RecConfigAbstract Set Status = Status | 64 where ID = @ID
	Update tbl_mERP_RecConfigDetail Set Status = Status | 64 where ID = @ID

	Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
	 Values( @ScrCode, @Errmessage, Null, GetDate())
End
