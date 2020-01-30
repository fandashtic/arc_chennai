CREATE procedure sp_acc_loadpendingapv(@partyid integer)
as

Declare @prefix nvarchar(10)

Create table #PendingDocument(Type nVarchar(30),FullDocumentID nVarchar(50),
DocumentDate Datetime,TotalAmount Decimal(18,6),Balance Decimal(18,6),
DocumentID Int,DocumentType Int,DocRef nVarchar(50),Narration nVarchar(4000))

select @prefix =Prefix from VoucherPrefix
where TranID = N'ACCOUNTS PAYABLE VOUCHER'

Insert into #PendingDocument
select dbo.LookupDictionaryItem('APV',Default),@prefix + cast(APVID as nvarchar(10)),APVDate,
'TotalAmount'=AmountApproved,'Balance'=isnull(Balance,0),DocumentID,
4,BillNo,APVRemarks from APVAbstract where [PartyAccountID]= @partyid
-- -- and isnull(Status,0)<> 192
and IsNull(Status, 0) & 128 = 0
and isnull(Balance ,0)<> 0

Insert into #PendingDocument
select dbo.LookupDictionaryItem('Credit Note',Default), VoucherPrefix.Prefix + cast(DocumentID as nvarchar),
DocumentDate, NoteValue, Balance, CreditID, 2 ,DocRef,Memo
from CreditNote, VoucherPrefix where Others = @PartyID and Balance > 0
and (IsNull(Status,0) & 64)= 0 and VoucherPrefix.TranID = N'CREDIT NOTE'

-- Service Invoice - Inward (Receivables)
Insert Into #PendingDocument
Select dbo.LookupDictionaryItem('Service Inward',Default), DocumentID, ServiceInvoiceDate, TotalNetAmount, Balance,
InvoiceID, 151, DocumentRef, ReferenceDescription
From ServiceAbstract S
Where Balance > 0 and isnull(Status,0) = 0 and ServiceType = 'Inward' and
((ServiceFor = 1 and Code = (Select Top 1 VendorID From Vendors Where AccountID = @PartyID))
OR (ServiceFor = 2 and Code = (Select Top 1 CustomerID From Customer Where AccountID = @PartyID)))


Select Type,FullDocumentID,DocumentDate,TotalAmount,Balance,
DocumentID,DocumentType,DocRef,Narration from #PendingDocument
order by DocumentDate

Drop table #PendingDocument

