
Create Procedure sp_get_BouncedInvoices (@CollectionID int)
as
Select FullDocID from Collections Where DocumentID = @CollectionID
Union
Select OriginalID From CollectionDetail Where CollectionID = @CollectionID

