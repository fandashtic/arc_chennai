Create Procedure mERP_sp_Update_LaunchErrorStatus(@RecdDocID Int, @ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('LAUNCHINFO', @ErrorMsg,  'Received LaunchDocID - ' + Cast(@RecdDocID as nVarchar(10)) ,GetDate())  
End
