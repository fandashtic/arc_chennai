CREATE procedure sp_IsBeforePaymentDate(@InvoiceID INT, @CollectionDt DateTime = NULL )  
As  
Declare @Count INT  
SELECT @Count = Count(*) FROM InvoiceAbstract Where InvoiceID = @InvoiceID  
And @CollectionDt <= PaymentDate  
IF @Count > 0   
SELECT 1  
ELSE  
SELECT 0  
  


