CREATE Procedure sp_acc_ser_RetrieveServiceInvoiceInfo (@InvoiceID INT)
As 
Select "InvoiceType" = ServiceInvoiceType,PaymentMode
from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID
