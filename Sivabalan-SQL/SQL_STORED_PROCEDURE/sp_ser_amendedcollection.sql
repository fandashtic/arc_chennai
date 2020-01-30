CREATE procedure sp_ser_amendedcollection(@CollectionID as int) 
as
Select c.OriginalID, c.DocumentDate, c.DocumentValue, c.AdjustedAmount,
c.DocumentType, c.ExtraCollection, c.DocRef, c.Adjustment, 
c.DocumentID, 'Type' = 'Service Invoice', 
i.Balance + c.AdjustedAmount + c.ExtraCollection + c.Adjustment, i.AdditionalDiscountPercentage
From CollectionDetail c
Inner Join ServiceInvoiceAbstract i On i.ServiceInvoiceID = c.DocumentID
Where c.CollectionID = @CollectionID and c.DocumentType = 12
