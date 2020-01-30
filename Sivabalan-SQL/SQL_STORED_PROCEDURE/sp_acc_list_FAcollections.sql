CREATE procedure sp_acc_list_FAcollections(@PartyID Int)
as

select "Document ID" = (VoucherPrefix.Prefix + cast(DocumentID as nvarchar)),
"Document Date" = DocumentDate, NoteValue, Balance, CreditID, "Type" = 2 , dbo.LookupDictionaryItem('Credit Note',Default),
0, DocRef,Memo from CreditNote, VoucherPrefix where Others = @PartyID and Balance > 0 and
VoucherPrefix.TranID = N'CREDIT NOTE'

Union All
select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value, Balance, DocumentID,
"Type" = 3, dbo.LookupDictionaryItem('Collections',Default),Null, DocReference,Narration from Collections where Balance > 0 and
Others = @PartyID and (IsNull(Status, 0) & 192) = 0 -- not Cancelled collections

Union All
select "Document ID" = VoucherPrefix.Prefix + CAST(APVID as nvarchar),
"Document Date" = APVDate, AmountApproved,Balance, DocumentID, "Type" = 6,dbo.LookupDictionaryItem('APV',Default),
0,"Remarks"=BillNo,APVRemarks
from APVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and
VoucherPrefix.TranID = N'Accounts Payable Voucher'

Union All
select "Document ID" = VoucherPrefix.Prefix + CAST(ARVID as nvarchar),
"Document Date" = ARVDate, Amount,Balance, DocumentID, "Type" = 4,dbo.LookupDictionaryItem('ARV',Default),
0,"Remarks"=DocRef,ARVRemarks
from ARVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and
VoucherPrefix.TranID = N'Accounts Receivable Voucher'

Union All
select "Document ID" = (cast(VoucherPrefix.Prefix as nvarchar) + cast(DocumentID as nvarchar)),
"DocumentDate" = DocumentDate, NoteValue,
Balance, DebitID, "Type" = 5,
case Flag
when 0 then
dbo.LookupDictionaryItem('Debit Note',Default)
when 1 then
dbo.LookupDictionaryItem('Bank Charges',Default)
when 2 then
dbo.LookupDictionaryItem('Bounced',Default)
end, 0, DocRef,Memo
from DebitNote, VoucherPrefix
where Balance > 0 and
Others = @PartyID and
VoucherPrefix.TranID = N'DEBIT NOTE'

Union All
select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value,Balance, DocumentID,
"Type" = 7,dbo.LookupDictionaryItem('Payments',Default), Null,Remarks,Narration from Payments where Balance > 0 and
Others = @PartyID and (IsNull(Status, 0) & 192) = 0 -- not Cancelled Payments
--order by documentdate

--Service Outward
Union All
Select "Document ID" =  DocumentID, "Document Date" = ServiceInvoiceDate, TotalNetAmount, Balance,
InvoiceID, "Type" = 153, dbo.LookupDictionaryItem('Service Outward',Default), 0, "Remarks" = DocumentRef,
ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Outward' and
((ServiceFor = 1 and Code = (Select Top 1 VendorID From Vendors Where AccountID = @PartyID))
OR (ServiceFor = 2 and Code = (Select Top 1 CustomerID From Customer Where AccountID = @PartyID)))

