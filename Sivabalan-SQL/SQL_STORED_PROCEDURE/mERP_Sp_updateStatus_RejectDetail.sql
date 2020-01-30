Create Procedure  mERP_Sp_updateStatus_RejectDetail ( @ID int, @FieldName nVarchar(200), @ScrCode nVarchar(255), @Errmessage nVarchar(255))
As
Declare @KeyValue nVarchar(255)
Begin
Update tbl_mERP_RecConfigDetail Set Status = Status | 64 where ID = @ID and FieldName = @FieldName
Insert Into tbl_mERP_RecdErrMessages ( TransactionType, ErrMessage, KeyValue, ProcessDate)
	 Values( @ScrCode, @Errmessage, Null, GetDate())
End
