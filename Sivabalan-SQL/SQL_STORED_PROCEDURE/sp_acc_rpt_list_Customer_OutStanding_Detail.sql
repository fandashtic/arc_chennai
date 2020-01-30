CREATE procedure sp_acc_rpt_list_Customer_OutStanding_Detail( @Customer nvarchar(15),  
       @FromDate datetime,    
       @ToDate datetime)    
as
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
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, dbo.Sp_Acc_GetOperatingDate(getdate())),    
"Doc Type" = case InvoiceAbstract.InvoiceType    
when 1 then dbo.LookupDictionaryItem('Invoice',Default) when 3 then dbo.LookupDictionaryItem('Invoice Amendment',Default) when 4 then dbo.LookupDictionaryItem('Sales Return',Default) else '' end
from InvoiceAbstract, VoucherPrefix as InvPrefix    
where InvoiceAbstract.CustomerID = @Customer and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.InvoiceType in (1, 3, 4) and    
InvoiceAbstract.Balance > 0 and    
InvPrefix.TranID = N'INVOICE'    
union    
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),   
DocRef,  
Creditnote.DocumentDate, Creditnote.Notevalue,    
0 - Creditnote.Balance ,    
datediff(dd, Creditnote.DocumentDate, dbo.Sp_Acc_GetOperatingDate(getdate())), dbo.LookupDictionaryItem('Credit Note',Default)  
from Creditnote, VoucherPrefix     
where 
((Creditnote.CustomerID is not null and Creditnote.CustomerID= @Customer) or
(Creditnote.Others is not null and  (Select Customer.AccountID from Customer where Customer.CustomerID = @Customer) =Creditnote.Others)) and
Creditnote.DocumentDate between @FromDate and @ToDate and    
Creditnote.Balance > 0 and    
Voucherprefix.TranID = N'CREDIT NOTE'    
    
union    
    
select debitnote.debitid,  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar),   
DocRef,   
Debitnote.DocumentDate,    
Debitnote.Notevalue,    
Debitnote.Balance ,    
datediff(dd, Debitnote.DocumentDate, dbo.Sp_Acc_GetOperatingDate(getdate())), dbo.LookupDictionaryItem('Debit Note',Default)  
from Debitnote, VoucherPrefix     
where 
((DebitNote.CustomerID is not null and DebitNote.CustomerID= @Customer) or
(DebitNote.Others is not null and  (Select Customer.AccountID from Customer where Customer.CustomerID = @Customer) =DebitNote.Others)) and
Debitnote.DocumentDate between @FromDate and @ToDate and    
Debitnote.Balance > 0 and    
Voucherprefix.TranID = N'DEBIT NOTE'   
  
union  
  
Select Collections.DocumentID, 
Collections.FullDocID, Null, Collections.DocumentDate,  
Collections.Value, 0 - Collections.Balance,   
DateDiff(dd, Collections.DocumentDate, dbo.Sp_Acc_GetOperatingDate(getdate())), dbo.LookupDictionaryItem('Advance',Default)  
From Collections  
Where 
Collections.DocumentDate Between @FromDate And @ToDate And  
Collections.Balance > 0 and
((Collections.CustomerID is not null and Collections.CustomerID= @Customer) or
(Collections.CustomerID is null and  (Select Customer.AccountID from Customer where Customer.CustomerID = @Customer) =Collections.Others)) 
  
Order By "Date", "Documentid" 

