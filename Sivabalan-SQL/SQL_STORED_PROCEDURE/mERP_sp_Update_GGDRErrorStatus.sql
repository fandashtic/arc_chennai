Create Procedure mERP_sp_Update_GGDRErrorStatus(@REC_GGRDID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('GGDR', @ErrorMsg,  'Received GGDR ID -  ' + Cast(@REC_GGRDID as nVarchar(10)) ,GetDate())  
End
