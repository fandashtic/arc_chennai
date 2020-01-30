Create Function mERP_FN_getInvAmtForTally(@Invoiceid int)
returns decimal(20,4)
AS
BEGIN
	Declare @Value decimal(20,4)
	select @Value = sum(Amount) from InvoiceDetail where InvoiceID=@Invoiceid and isnull(TaxCode,0)=0 and isnull(STPayable,0)=0
	return @Value 
END 
