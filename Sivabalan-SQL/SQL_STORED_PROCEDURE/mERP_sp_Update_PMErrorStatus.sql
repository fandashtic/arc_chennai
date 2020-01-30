Create Procedure mERP_sp_Update_PMErrorStatus(@REC_PMID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('ITCPM', @ErrorMsg,  'Received PMID -  ' + Cast(@REC_PMID as nVarchar(10)) ,GetDate())  
	Update tbl_mERP_Recd_PMMaster Set Status = 64 Where REC_PMID = @REC_PMID	
End
