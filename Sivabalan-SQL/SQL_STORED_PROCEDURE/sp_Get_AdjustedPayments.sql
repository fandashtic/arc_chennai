CREATE Procedure sp_Get_AdjustedPayments (@BillID Int)
As
Declare @PaymentID Int
Select @PaymentID = PaymentID From BillAbstract Where BillID = @BillID

Select DocumentType, OriginalID, DocumentDate, DocumentID, AdjustedAmount, DocumentValue, 
DocumentReference From PaymentDetail 
Where PaymentID = @PaymentID And
DocumentType in (1, 3, 6)
Union
Select DocumentType, OriginalID, DocumentDate, DocumentID, AdjustedAmount, DocumentValue, 
DocumentReference From PaymentDetail 
Where PaymentID = @PaymentID And 
DocumentType = 5 And DocumentID Not In (Select ReferenceID From AdjustmentReference
Where InvoiceID = @BillID and TransactionType = 1)
Union
Select DocumentType, OriginalID, DocumentDate, DocumentID, AdjustedAmount, DocumentValue, 
DocumentReference From PaymentDetail 
Where PaymentID = @PaymentID And 
DocumentType = 2 And DocumentID Not In (Select ReferenceID From AdjustmentReference
Where InvoiceID = @BillID and TransactionType = 1)

