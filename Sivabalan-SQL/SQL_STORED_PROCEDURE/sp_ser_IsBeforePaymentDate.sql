Create procedure sp_ser_IsBeforePaymentDate(@InvoiceID INT, @CollectionDt DateTime )  
As  
SELECT "Status" = Count(*) 
FROM ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID  
And @CollectionDt <= PaymentDate  

