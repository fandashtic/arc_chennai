Create Procedure mERP_sp_Update_PMOutletAchErrorStatus(@REC_PMID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('PMTGTACH', @ErrorMsg,  'Received PMTGTACHID -  ' + Cast(@REC_PMID as nVarchar(10)) ,GetDate())  
End
