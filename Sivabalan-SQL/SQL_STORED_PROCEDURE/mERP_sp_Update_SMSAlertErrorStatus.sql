Create Procedure mERP_sp_Update_SMSAlertErrorStatus(@REC_ID Int,@ErrorMsg  nVarchar(510))
As
Begin
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)      
	Values('SMSALERT', @ErrorMsg,  'Received SMSALERT ID -  ' + Cast(@REC_ID as nVarchar(10)) ,GetDate())  
	Update Recd_OCG Set Status = 64 Where ID = @REC_ID and Isnull(Status ,0) = 0	
End
