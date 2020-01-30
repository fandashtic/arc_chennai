Create Procedure merp_sp_IsGVAdjusted(@InvNo as Int) 
As
If Exists ( Select InvoiceID from CollectionDetail where InvoiceID = @InvNo and DocumentType = 10)
	Select 1 As GVAdjusted
Else
	Select 0 As GVAdjusted

