CREATE Procedure sp_acc_GetAmendedFACollection(@CollectionID Int)
As

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Credit Note',Default),
CreditNote.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
CreditNote.Memo
From CollectionDetail, CreditNote
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 2 And
CreditNote.CreditID = CollectionDetail.DocumentID

Union ALL

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Collections',Default),
Collections.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
Collections.Narration
From CollectionDetail, Collections
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 3 And
Collections.DocumentID = CollectionDetail.DocumentID

Union ALL

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID,dbo.LookupDictionaryItem('APV',Default),
APVAbstract.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
APVAbstract.APVRemarks
From CollectionDetail, APVAbstract
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 6 And
APVAbstract.DocumentID = CollectionDetail.DocumentID

Union All

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Debit Note',Default),
DebitNote.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
DebitNote.Memo
From CollectionDetail, DebitNote
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 5 And
DebitNote.DebitID = CollectionDetail.DocumentID

Union ALL

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('ARV',Default),
ARVAbstract.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
ARVAbstract.ARVRemarks
From CollectionDetail, ARVAbstract
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 4 And
ARVAbstract.DocumentID = CollectionDetail.DocumentID

Union ALL

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Payments',Default),
Payments.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
Payments.Narration
From CollectionDetail, Payments
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 7 And
Payments.DocumentID = CollectionDetail.DocumentID

--Service Invoice Outward
Union ALL

Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,
CollectionDetail.DocRef, CollectionDetail.Adjustment,
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Service Outward',Default),
ServiceAbstract.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,
ServiceAbstract.ReferenceDescription
From CollectionDetail, ServiceAbstract
Where CollectionDetail.CollectionID = @CollectionID And
CollectionDetail.DocumentType = 153 And
ServiceAbstract.InvoiceID = CollectionDetail.DocumentID

