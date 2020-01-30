CREATE procedure sp_CancelServiceInvoice
(
@Invoicenumber int
)
As
BEGIN
Declare @InvoiceID Int
Declare @ServiceType nVarchar(50)

Update ServiceAbstract set status=4,Balance=0,Canceldate=getdate() where ServiceInvoiceNo=@Invoicenumber

Select @InvoiceID = InvoiceID, @ServiceType = ServiceType
From ServiceAbstract where ServiceInvoiceNo = @Invoicenumber

If(@ServiceType = 'Inward')
Begin
Exec sp_acc_gj_inputserviceinvoicecancel @InvoiceID
End
Else
Begin
Exec sp_acc_gj_outputserviceinvoicecancel @InvoiceID
End
END
