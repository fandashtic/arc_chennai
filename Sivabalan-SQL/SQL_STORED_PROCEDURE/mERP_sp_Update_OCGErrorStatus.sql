Create Procedure mERP_sp_Update_OCGErrorStatus(@REC_OCGID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('OCGDS', @ErrorMsg,  'Received OCG ID -  ' + Cast(@REC_OCGID as nVarchar(10)) ,GetDate())  
	Update Recd_OCG Set Status = 64 Where ID = @REC_OCGID and Isnull(Status ,0) = 0	
End
