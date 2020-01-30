Create Procedure mERP_sp_Update_CLOCRNOTEErrorStatus(@RecdDocID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('CLOCRNOTE', @ErrorMsg,  'Received CLOCRNOTEID -  ' + Cast(@RecdDocID as nVarchar(10)) ,GetDate())  
End
