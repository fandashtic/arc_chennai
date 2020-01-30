
CREATE procedure spc_PaymentDetail (@PaymentID int)
as
select PaymentID, DocumentDate, PaymentDate, DocumentID, DocumentType, AdjustedAmount, 
OriginalID, DocumentValue, DocumentReference
From PaymentDetail
Where PaymentID = @PaymentID

