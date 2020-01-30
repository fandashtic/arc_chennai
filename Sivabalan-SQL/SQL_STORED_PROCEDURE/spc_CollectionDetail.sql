CREATE procedure spc_CollectionDetail (@CollectionID int)
as
select CollectionID, DocumentDate, PaymentDate, DocumentType, AdjustedAmount, OriginalID, 
DocumentValue, ExtraCollection, Adjustment
From CollectionDetail 
Where CollectionDetail.CollectionID = @CollectionID
