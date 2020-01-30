CREATE procedure sp_list_Amendcollections(@CustomerID nvarchar(15),    
       @CollectionID int)    
as    
select "DocumentID" = VoucherPrefix.Prefix + CAST(DocumentID as nvarchar),     
"DocumentDate" = InvoiceDate,     
NetValue, Balance, InvoiceID, "Type" = 1, dbo.LookupDictionaryItem(N'Sales Return', default), AdditionalDiscount, DocReference    
from invoiceabstract, VoucherPrefix    
where InvoiceType = 4 and    
IsNull(Status, 0) & 128 = 0 and    
CustomerID = @CustomerID and    
ISNULL(Balance, 0) > 0 and    
VoucherPrefix.TranID = 'SALES RETURN' and    
InvoiceID Not in (Select DocumentID From CollectionDetail     
Where CollectionID = @CollectionID And DocumentType = 1)    
    
union    
    
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),     
"DocumentDate" = DocumentDate,     
NoteValue, Balance, CreditID, "Type" = 2,
dbo.LookupDictionaryItem(Case IsNULL(Flag,0)
When 7 then
N'Sales Return'
When 8 then
N'Advance Collection'
Else
N'Credit Note'
End, Default), 0, DocRef    
from CreditNote, VoucherPrefix    
where CustomerID = @CustomerID and    
Balance > 0 and     
VoucherPrefix.TranID = 'CREDIT NOTE' and    
CreditID Not in (Select DocumentID From CollectionDetail     
Where CollectionID = @CollectionID And DocumentType = 2)    
    
union    
    
select "DocumentID" = FullDocID,     
"DocumentDate" = DocumentDate, Value,     
Balance, DocumentID, "Type" = 3, dbo.LookupDictionaryItem(N'Collections', Default) ,0, Null    
from Collections, VoucherPrefix    
where Balance > 0 and    
CustomerID = @CustomerID and    
(IsNull(Status, 0) & 192) = 0 And -- Cancelled collections    
VoucherPrefix.TranID = 'COLLECTIONS' and    
DocumentID Not in (Select DocumentID From CollectionDetail     
Where CollectionID = @CollectionID And DocumentType = 3) And
DocumentID Not in (Select @CollectionID)    
    
union    
    
select     
"DocumentID" =     
case InvoiceType    
when 1 then    
  VoucherPrefix.Prefix     
when 2 then    
  VoucherPrefix.Prefix     
when 3 then    
  InvPrefix.Prefix    
end    
+ CAST(DocumentID as nvarchar), "DocumentDate" = InvoiceDate, NetValue,     
Balance, InvoiceID, "Type" = 4,    
dbo.LookupDictionaryItem(case InvoiceType    
when 1 then    
  N'Invoice'    
when 2 then    
  N'Retail Invoice'    
when 3 then    
  N'Invoice Amd'    
end, Default),
AdditionalDiscount, DocReference    
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix    
where InvoiceType in (1, 3 ,2) and    
IsNull(Status, 0) & 128 = 0 and    
CustomerID = @CustomerID and    
ISNULL(Balance, 0) > 0 and    
VoucherPrefix.TranID = 'INVOICE' and    
InvPrefix.TranID = 'INVOICE AMENDMENT' and    
InvoiceID Not in (Select DocumentID From CollectionDetail     
Where CollectionID = @CollectionID And (DocumentType = 4 or DocumentType=6))    
    
union    
    
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),     
"DocumentDate" = DocumentDate, NoteValue,     
Balance, DebitID, "Type" = 5,     
dbo.LookupDictionaryItem(case Flag    
when 0 then    
'Debit Note'    
when 1 then    
'Bank Charges'    
when 2 then    
'Bounced'    
When 4 then
'Debit Note'
When 5 then
'Invoice'
end, Default), 0, DocRef    
from DebitNote, VoucherPrefix    
where Balance > 0 and     
CustomerID = @CustomerID and     
VoucherPrefix.TranID = 'DEBIT NOTE' and    
DebitID Not in (Select DocumentID From CollectionDetail     
Where CollectionID = @CollectionID And DocumentType = 5)        
order by DocumentDate    
