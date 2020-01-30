CREATE procedure spr_list_cash_PaymentDetail(@DocumentId integer)    
as    


Declare @PURCHASERETURN nVarchar(50)
Declare @DEBITNOTE nVarchar(50)
Declare @PAYMENTS nVarchar(50)
Declare @PURCHASE nVarchar(50)
Declare @CREDITNOTE nVarchar(50)

SElect @PURCHASERETURN = dbo.LookupDictionaryItem(N'Purchase Return',Default)
SElect @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note',Default)
SElect @PAYMENTS = dbo.LookupDictionaryItem(N'Payments',Default)
SElect @PURCHASE = dbo.LookupDictionaryItem(N'Purchase',Default)
SElect @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note',Default)

select PaymentDetail.OriginalID,    
"Document ID" = PaymentDetail.OriginalID,    
"Document Date" = PaymentDetail.DocumentDate,    
"Document Type" = case DocumentType    
when 1 then    
@PURCHASERETURN
when 2 then    
@DEBITNOTE
when 3 then    
@PAYMENTS   
when 4 then    
@PURCHASE  
when 5 then    
@CREDITNOTE  
end,    
"Doc Ref" = PaymentDetail.DocumentReference,
"Document Value" = PaymentDetail.DocumentValue,
"Amount" = PaymentDetail.AdjustedAmount,
"Addl Adj." = PaymentDetail.ExtraCol
from PaymentDetail    
where PaymentID = @DocumentId

