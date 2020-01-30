Create Procedure mERP_sp_Update_OLTPMErrorStatus(@REC_PMID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('PMOLT', @ErrorMsg,  'Received PMOLTID -  ' + Cast(@REC_PMID as nVarchar(10)) ,GetDate())  
End
