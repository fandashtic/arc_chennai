CREATE procedure sp_acc_list_AmendFACollections(@PartyID Int, @CollectionID Int)
as

Select "Document ID" = (VoucherPrefix.Prefix + cast(DocumentID as nvarchar)),
"Document Date" = DocumentDate, NoteValue, Balance, CreditID, "Type" = 2 , 'Credit Note',
0, DocRef,Memo from CreditNote, VoucherPrefix where Others = @PartyID and Balance > 0 and
VoucherPrefix.TranID = N'CREDIT NOTE' and
CreditID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 2)

Union All
Select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value, Balance, DocumentID,
"Type" = 3, 'Collections',Null, DocReference,Narration from Collections where Balance > 0 and
Others = @PartyID and (IsNull(Status, 0) & 192) = 0 and
DocumentID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 3)And
DocumentID Not In (@CollectionID)

Union All
Select "Document ID" = VoucherPrefix.Prefix + CAST(APVID as nvarchar),
"Document Date" = APVDate, AmountApproved,Balance, DocumentID, "Type" = 6,'APV',
0,"Remarks"=BillNo,APVRemarks
from APVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and
VoucherPrefix.TranID = N'Accounts Payable Voucher' and
DocumentID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 6)

Union All
Select "Document ID" = VoucherPrefix.Prefix + CAST(ARVID as nvarchar),
"Document Date" = ARVDate, Amount,Balance, DocumentID, "Type" = 4,'ARV',
0,"Remarks"=DocRef,ARVRemarks
from ARVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and
VoucherPrefix.TranID = N'Accounts Receivable Voucher' and
DocumentID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 4)

Union All
Select "Document ID" = (cast(VoucherPrefix.Prefix as nvarchar) + cast(DocumentID as nvarchar)),
"DocumentDate" = DocumentDate, NoteValue,
Balance, DebitID, "Type" = 5,
case Flag
when 0 then
'Debit Note'
when 1 then
'Bank Charges'
when 2 then
'Bounced'
end, 0, DocRef,Memo
from DebitNote, VoucherPrefix
where Balance > 0 and
Others = @PartyID and
VoucherPrefix.TranID = N'DEBIT NOTE'  and
DebitID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 5)

Union All
Select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value,Balance, DocumentID,
"Type" = 7,'Payments', Null,Remarks,Narration from Payments where Balance > 0 and
Others = @PartyID and (IsNull(Status, 0) & 192) = 0  and
DocumentID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 7)

--Service Invoice Outward
Union All
Select "Document ID" = DocumentID,
"Document Date" = ServiceInvoiceDate, TotalNetAmount,Balance, DocumentID, "Type" = 153,'Service Outward',
0,"Remarks"=DocumentRef,ReferenceDescription
From ServiceAbstract
Where
Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Outward' and
((ServiceFor = 1 and Code = (Select Top 1 VendorID From Vendors Where AccountID = @PartyID))
OR (ServiceFor = 2 and Code = (Select Top 1 CustomerID From Customer Where AccountID = @PartyID)))
and InvoiceID Not in (Select DocumentID From CollectionDetail
Where CollectionID = @CollectionID And DocumentType = 153)

