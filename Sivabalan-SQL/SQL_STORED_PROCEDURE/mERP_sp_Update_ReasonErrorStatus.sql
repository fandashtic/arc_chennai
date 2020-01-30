Create Procedure mERP_sp_Update_ReasonErrorStatus(@RecdDocID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('ReasonMaster', @ErrorMsg,  'Received ReasonID -  ' + Cast(@RecdDocID as nVarchar(10)) ,GetDate())  
End
