CREATE procedure spr_ser_list_Customer_OutStanding_Detail( @Customer nvarchar(15),  
       @FromDate datetime,    
       @ToDate datetime)    
as
declare @invtype nvarchar(100)    

select InvoiceAbstract.InvoiceID,     
"Documentid" =     
InvPrefix.Prefix    
+ cast(InvoiceAbstract.DocumentID as varchar),    
"Doc Reference"=DocReference,    
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType    
when 4 then 0 - InvoiceAbstract.NetValue when 5 then 0 - InvoiceAbstract.NetValue 
when 6 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,    
"Balance" = case InvoiceType     
     when 4 then 0 - InvoiceAbstract.Balance when 5 then 0 - InvoiceAbstract.Balance
	when 6 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,     
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),    
"Doc Type" = case InvoiceAbstract.InvoiceType    
when 1 then 'Invoice' when 2 then 'Retail Invoice' when 3 then 'Invoice Amendment' 
when 4 then 'Sales Return' when 5 then 'Sales Return Saleable' when 6 then 'Sales Return Damages' else '' end
from InvoiceAbstract, VoucherPrefix as InvPrefix    
where InvoiceAbstract.CustomerID = @Customer and    
InvoiceAbstract.Status & 128 = 0 and    
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and    
InvoiceAbstract.Balance > 0 and    
InvPrefix.TranID = 'INVOICE'    
union    
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as varchar),   
DocRef,  
Creditnote.DocumentDate, Creditnote.Notevalue,    
0 - Creditnote.Balance ,    
datediff(dd, Creditnote.DocumentDate, GetDate()), 'Credit Note'  
from Creditnote, VoucherPrefix     
where Creditnote.CustomerID = @Customer and    
Creditnote.DocumentDate between @FromDate and @ToDate and    
Creditnote.Balance > 0 and    
Voucherprefix.TranID = 'CREDIT NOTE'    
    
union    
    
select debitnote.debitid,  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as varchar),   
DocRef,   
Debitnote.DocumentDate,    
Debitnote.Notevalue,    
Debitnote.Balance ,    
datediff(dd, Debitnote.DocumentDate, GetDate()), 'Debit Note'  
from Debitnote, VoucherPrefix     
where Debitnote.CustomerID = @Customer and    
Debitnote.DocumentDate between @FromDate and @ToDate and    
Debitnote.Balance > 0 and    
Voucherprefix.TranID = 'DEBIT NOTE'   
  
union  
  
Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,  
Collections.Value, 0 - Collections.Balance,   
DateDiff(dd, Collections.DocumentDate, GetDate()), 'Advance'  
From Collections  
Where Collections.CustomerID = @Customer And  
Collections.DocumentDate Between @FromDate And @ToDate And  
Collections.Balance > 0  


union

select SerAbs.ServiceInvoiceID,     
"Documentid" = SerPrefix.Prefix + cast(SerAbs.DocumentID as varchar),    
"Doc Reference"=DocReference,    
"Date" = SerAbs.ServiceInvoiceDate, "Amount" = SerAbs.NetValue,    
"Balance" = SerAbs.Balance,
"Due Days" = datediff(dd, SerAbs.ServiceInvoiceDate, GetDate()),    
"Doc Type" = 'Service Invoice'
from ServiceInvoiceAbstract SerAbs, VoucherPrefix as SerPrefix    
where SerAbs.CustomerID = @Customer and    
IsNull(SerAbs.Status,0) & 192 = 0 and    
SerAbs.ServiceInvoiceDate between @FromDate and @ToDate and    
SerAbs.ServiceInvoiceType = 1 and
SerAbs.Balance > 0 and    
SerPrefix.TranID = 'SERVICEINVOICE' 

Order By "Date", "Documentid"  


