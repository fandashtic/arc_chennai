Create Procedure sp_ApplyInvScheme_CustQuote 
	@QuotationId int
As
	Select AllowInvoiceScheme 
	From QuotationAbstract 
	Where QuotationID = @QuotationID


