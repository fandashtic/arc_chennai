CREATE Procedure sp_list_collections(@CustomerID nvarchar(15))      
as      
select "DocumentID" = 
Case IsNULL(GSTFlag ,0)
When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar)                        
Else
	IsNULL(GSTFullDocID,'')
End,
--"DocumentID" = VoucherPrefix.Prefix + CAST(DocumentID as nvarchar),       
"DocumentDate" = InvoiceDate, NetValue, Balance,   
InvoiceID,"Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,  
dbo.LookupDictionaryItem('Sales Return', Default), AdditionalDiscount, DocReference      
from invoiceabstract, VoucherPrefix      
where InvoiceType in(4,5,6) and      
IsNull(Status, 0) & 128 = 0 and      
CustomerID = @CustomerID and      
ISNULL(Balance, 0) > 0 and      
VoucherPrefix.TranID = 'SALES RETURN'      
    
union      
      
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),       
"DocumentDate" = DocumentDate,       
NoteValue, Balance, CreditID, "Type" = 2,
dbo.LookupDictionaryItem(Case IsNULL(Flag,0)
When 7 then
'Sales Return'
When 8 then
'Advance Collection'
Else
'Credit Note'
end, Default), 0, DocRef      
from CreditNote, VoucherPrefix      
where CustomerID = @CustomerID and      
Balance > 0 and      
VoucherPrefix.TranID = 'CREDIT NOTE' 
and CreditNote.Flag In (0,1)
and creditid not in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)

union      
      
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),       
"DocumentDate" = DocumentDate,       
NoteValue, Balance, CreditID, "Type" = 2,
dbo.LookupDictionaryItem(Case IsNULL(Flag,0)
When 7 then
'Sales Return'
When 8 then
'Advance Collection'
Else
'Credit Note'
end, Default), 0, DocRef      
from CreditNote, VoucherPrefix      
where CustomerID = @CustomerID and      
Balance > 0 and      
VoucherPrefix.TranID = 'GIFT VOUCHER'
and CreditNote.Flag =1 
and creditid in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)
      
union      
      
select "DocumentID" = FullDocID,       
"DocumentDate" = DocumentDate, Value,       
Balance, DocumentID, "Type" = 3, dbo.LookupDictionaryItem('Collections', Default), 0, Null      
from Collections, VoucherPrefix      
where Balance > 0 and      
CustomerID = @CustomerID and      
(IsNull(Status, 0) & 192) = 0 And -- Cancelled collections      
VoucherPrefix.TranID = 'COLLECTIONS'      
      
union      
      
select     
"DocumentID" =    
Case IsNULL(GSTFlag ,0)
When 0 then 
	case InvoiceType                        
	when 1 then             
	 VoucherPrefix.Prefix                         
	When 2 then                  
	 RPrefix.Prefix                  
	when 3 then                        
	 InvPrefix.Prefix                       
	end     
	+ CAST(DocumentID as nvarchar)                   
Else
	IsNULL(GSTFullDocID,'')
End,
"DocumentDate" = InvoiceDate, NetValue,       
Balance, InvoiceID, "Type" = case InvoiceType     
 when 1 then   4      
 when 2 then   6      
 when 3 then   4 end,      
dbo.LookupDictionaryItem(case InvoiceType      
when 1 then      
  'Invoice'      
when 2 then      
  'Retail Invoice'      
when 3 then      
  'Invoice Amd'      
end, Default),
AdditionalDiscount, DocReference      
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix, VoucherPrefix as RPrefix
where InvoiceType in (1, 3, 2) and      
IsNull(Status, 0) & 128 = 0 and      
CustomerID = @CustomerID and      
ISNULL(Balance, 0) > 0 and      
VoucherPrefix.TranID = 'INVOICE' and      
InvPrefix.TranID = 'INVOICE AMENDMENT' And
RPrefix.TranID = 'RETAIL INVOICE'
      
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
VoucherPrefix.TranID = 'DEBIT NOTE'      
      
order by DocumentDate      
