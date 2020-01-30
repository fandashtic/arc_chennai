CREATE Procedure sp_acc_GetAmendedFAPayment(@PaymentID Int)
As
Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('Credit Note',Default),
CreditNote.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
CreditNote.Memo
From PaymentDetail, CreditNote
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 2 And
CreditNote.CreditID = PaymentDetail.DocumentID

Union ALL

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('Collections',Default),
Collections.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
Collections.Narration
From PaymentDetail, Collections
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 7 And
Collections.DocumentID = PaymentDetail.DocumentID

Union ALL

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID,dbo.LookupDictionaryItem('APV',Default),
APVAbstract.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
APVAbstract.APVRemarks
From PaymentDetail, APVAbstract
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 4 And
APVAbstract.DocumentID = PaymentDetail.DocumentID

Union All

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('Debit Note',Default),
DebitNote.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
DebitNote.Memo
From PaymentDetail, DebitNote
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 5 And
DebitNote.DebitID = PaymentDetail.DocumentID

Union ALL

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('ARV',Default),
ARVAbstract.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
ARVAbstract.ARVRemarks
From PaymentDetail, ARVAbstract
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 6 And
ARVAbstract.DocumentID = PaymentDetail.DocumentID

Union ALL

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('Payments',Default),
Payments.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
Payments.Narration
From PaymentDetail, Payments
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 3 And
Payments.DocumentID = PaymentDetail.DocumentID

Union All
Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID, dbo.LookupDictionaryItem('ManualJournal - New Reference',Default),
ManualJournal.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
ManualJournal.Remarks
From PaymentDetail, ManualJournal
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType In (8,9) And
ManualJournal.NewRefID = PaymentDetail.DocumentID

Union ALL

Select PaymentDetail.OriginalID, PaymentDetail.DocumentDate,
PaymentDetail.DocumentValue, PaymentDetail.AdjustedAmount,
PaymentDetail.DocumentType, PaymentDetail.ExtraCol,
PaymentDetail.DocumentReference, PaymentDetail.Adjustment,
PaymentDetail.DocumentID,dbo.LookupDictionaryItem('Service Inward',Default),
ServiceAbstract.Balance + PaymentDetail.AdjustedAmount + PaymentDetail.ExtraCol + PaymentDetail.Adjustment,
ServiceAbstract.ReferenceDescription
From PaymentDetail, ServiceAbstract
Where PaymentDetail.PaymentID = @PaymentID And
PaymentDetail.DocumentType = 151 And
ServiceAbstract.InvoiceID = PaymentDetail.DocumentID

