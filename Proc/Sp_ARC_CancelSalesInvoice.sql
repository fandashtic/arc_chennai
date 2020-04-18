--Exec Sp_ARC_CancelSalesInvoice 'I/19-20/50970'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'Sp_ARC_CancelSalesInvoice')
BEGIN
    DROP PROC Sp_ARC_CancelSalesInvoice
END
GO
Create Proc Sp_ARC_CancelSalesInvoice (@GSTFullDocID Nvarchar(255), @Reason Nvarchar(255) = 'Delay in Delivery', @User Nvarchar(255) = 'dev')
AS
BEGIN
	Declare @InvoiceID AS INT
	Declare @InvoiceDate AS DATETIME

	set dateformat dmy
	select @InvoiceID = InvoiceID, @InvoiceDate = dbo.StripDateFromTime(InvoiceDate) 
	from InvoiceAbstract With (Nolock) 
	where GSTFullDocID = @GSTFullDocID 
	And InvoiceType in (1, 3)

	--exec sp_acc_retrieveinvoiceinfo @InvoiceID
	exec sp_Cancel_Invoice_Claims @InvoiceID,1
	exec sp_cancel_invoice @InvoiceID,@Reason,@User
	exec sp_adjust_opening_for_cancel_invoice @InvoiceID,@InvoiceDate,0,0
	exec sp_acc_gj_invoicecancel @InvoiceID,@InvoiceDate
	exec sp_update_CustomerPoints @InvoiceID,1

	Print 'Cancelled ' + @GSTFullDocID
END
GO