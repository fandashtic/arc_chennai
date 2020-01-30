Create Procedure sp_Get_PaymentAdjustment (@PaymentID Int)
As
Select OriginalID, DocumentDate, DocumentValue, AdjustedAmount, DocumentType, 
DocumentReference
From PaymentDetail
Where PaymentID = @PaymentID
