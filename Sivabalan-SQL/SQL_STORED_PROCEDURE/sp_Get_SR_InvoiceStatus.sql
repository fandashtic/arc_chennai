Create PROCEDURE sp_Get_SR_InvoiceStatus(@InvoiceID int)  
AS
	Declare @Result int
	Set @Result = 0

	IF Exists(Select 'x' From InvoiceAbstract Where isnull(SRInvoiceID,0) = @InvoiceID and (Status & 128) = 0 and InvoiceType = 4)
		Set @Result = 1

	Select "Result" = @Result
