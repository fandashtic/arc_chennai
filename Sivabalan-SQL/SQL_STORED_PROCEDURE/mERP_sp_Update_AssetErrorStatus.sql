Create Procedure mERP_sp_Update_AssetErrorStatus(@RecdDocID Int, @ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('ASSETTRACKER', @ErrorMsg,  'Received AssetDocID - ' + Cast(@RecdDocID as nVarchar(10)) ,GetDate())  
End
