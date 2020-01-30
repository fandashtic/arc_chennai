Create PROCEDURE sp_UpdateStatus_HHSR(@HHSRNo nvarchar(100), @Flag int, @InvoiceID int, @SRInvoiceID int)  
AS
	Declare @Processed int
	
	IF(Select Sum(isnull(PendingQty,0)) From Stock_Return Where ReturnNumber = @HHSRNo and ReturnType = @Flag and Processed = 3) = 0
		Set @Processed = 1
	Else
		Set @Processed = 3

	Update InvoiceAbstract Set SRHH_Reference = @HHSRNo Where InvoiceID = @InvoiceID

	Update Stock_Return Set 
		Invoice_Reference = Case When isnull(Invoice_Reference,'') <> '' Then isnull(Invoice_Reference,'') + ',' + Cast(@SRInvoiceID as nvarchar(50)) Else Cast(@SRInvoiceID as nvarchar(50)) End,
		SR_Reference = Case When isnull(SR_Reference,'') <> '' Then isnull(SR_Reference,'') + ',' + Cast(@InvoiceID as nvarchar(50)) Else Cast(@InvoiceID as nvarchar(50)) End,
		Processed = @Processed
	Where ReturnNumber = @HHSRNo and ReturnType = @Flag and Processed = 3

