CREATE procedure sp_GetAmend_GSTSerialNo(@InvNo int)                          
as    
BEGIN                                 
	Select isnull(GSTFullDocID,'') as GSTFullDocID, isnull(GSTFlag,0) as GSTFlag From InvoiceAbstract Where InvoiceID = @InvNo  
End
