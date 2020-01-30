CREATE procedure spr_list_Customer_OutStanding_Detail_PIDILITE( @Customer nvarchar(15),
@GraceDays int)    
as

Declare @INVOICE NVarchar(50)
Declare @SALESRETURN NVarchar(50)
Declare @INVOICEAMENDMENT NVarchar(50)
Declare @CREDITNOTE NVarchar(50)
Declare @DEBITNOTE NVarchar(50)
Declare @ADVANCE NVarchar(50)

Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)
Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)

declare @invtype nvarchar(100)    
select InvoiceAbstract.InvoiceID,     
"Documentid" =   
InvPrefix.Prefix
+ cast(InvoiceAbstract.DocumentID as nvarchar),    
"Doc Reference"=DocReference,    
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType    
when 4 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,    
"Balance" = case InvoiceType     
   when 4 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,     
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),    
"Doc Type" = case InvoiceAbstract.InvoiceType    
when 1 then @INVOICE when 3 then @INVOICEAMENDMENT when 4 then @SALESRETURN else N'' end
from InvoiceAbstract, VoucherPrefix as InvPrefix    
where InvoiceAbstract.CustomerID = @Customer and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceDate <=getdate() and dateadd(d,@GraceDays,paymentdate)<=getdate() and
InvoiceAbstract.InvoiceType in (1, 3, 4) and    
InvoiceAbstract.Balance > 0 and    
InvPrefix.TranID = N'INVOICE'    
union    
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),   
DocRef,  
Creditnote.DocumentDate, Creditnote.Notevalue,    
0 - Creditnote.Balance ,    
datediff(dd, Creditnote.DocumentDate, GetDate()), @CREDITNOTE
from Creditnote, VoucherPrefix     
where Creditnote.CustomerID = @Customer and    
Creditnote.DocumentDate <=getdate() and    
Creditnote.Balance > 0 and    
Voucherprefix.TranID = N'CREDIT NOTE'    
    
union    
    
select debitnote.debitid,  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar),   
DocRef,   
Debitnote.DocumentDate,    
Debitnote.Notevalue,    
Debitnote.Balance ,    
datediff(dd, Debitnote.DocumentDate, GetDate()), @DEBITNOTE
from Debitnote, VoucherPrefix     
where Debitnote.CustomerID = @Customer and    
Debitnote.DocumentDate <= getdate() and    
Debitnote.Balance > 0 and    
Voucherprefix.TranID = N'DEBIT NOTE'   
  
union  
  
Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,  
Collections.Value, 0 - Collections.Balance,   
DateDiff(dd, Collections.DocumentDate, GetDate()), @ADVANCE
From Collections  
Where Collections.CustomerID = @Customer And  
Collections.DocumentDate <= getdate() And  
Collections.Balance > 0  
  
Order By "Date", "Documentid"  



