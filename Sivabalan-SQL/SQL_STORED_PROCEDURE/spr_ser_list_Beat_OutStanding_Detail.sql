CREATE procedure spr_ser_list_Beat_OutStanding_Detail( @Customer nvarchar(155))
--       @FromDate datetime,    
--       @ToDate datetime)    
as    
Declare @BeatID int  
Declare @CustomerID nvarchar(20)  
Declare @Pos int  
Declare @Length int  

Set @Length = Len(@Customer)  
Set @Pos = CharIndex(';', @Customer, 1)  
Set @Length = @Length - @Pos  
Set @BeatID = Cast(SubString(@Customer, @Pos + 1, @Length) as int)  
Set @CustomerID = SubString(@Customer, 1, @Pos - 1)  

select InvoiceAbstract.InvoiceID,     
"DocumentID" = InvPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar),    
"Doc Reference"=InvoiceAbstract.DocReference,    
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType    
when 4 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,    
"Balance" = case InvoiceType 
when 4 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,     
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),    
"Invoice Type" = case InvoiceAbstract.InvoiceType    
when 1 then 'Invoice' when 3 then 'Invoice Amendment' when 4 then 'Sales Return' else '' end    
from InvoiceAbstract, VoucherPrefix as InvPrefix    
where InvoiceAbstract.CustomerID = @CustomerID and    
InvoiceAbstract.Status & 128 = 0 and    
--InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.InvoiceType in (1, 3, 4) and    
InvoiceAbstract.Balance > 0 and    
InvPrefix.TranID = 'INVOICE' and  
IsNull(InvoiceAbstract.BeatID, 0) = IsNull(@BeatID,0)

--Begin: Service Invoice Impact
union

select ServiceInvoiceAbstract.ServiceInvoiceID,     
"DocumentID" = InvPrefix.Prefix + cast(ServiceInvoiceAbstract.DocumentID as nvarchar),    
"Doc Reference"=ServiceInvoiceAbstract.DocReference,    
"Date" = ServiceInvoiceAbstract.ServiceInvoiceDate, 
"Amount" = ServiceInvoiceAbstract.NetValue,    
"Balance" = ServiceInvoiceAbstract.Balance,     
"Due Days" = datediff(dd, ServiceInvoiceAbstract.ServiceInvoiceDate, GetDate()),    
"Invoice Type" = case isNull(ServiceInvoiceAbstract.ServiceInvoiceType,0)
when 1 then 'Service Invoice' else '' end    
from ServiceInvoiceAbstract, VoucherPrefix as InvPrefix    
where 
ServiceInvoiceAbstract.CustomerID = @CustomerID and    
ServiceInvoiceAbstract.Status & 192 = 0 and    
--InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
ServiceInvoiceAbstract.ServiceInvoiceType in (1) and    
ServiceInvoiceAbstract.Balance > 0 and    
InvPrefix.TranID = 'SERVICEINVOICE' and
isNull(@BeatID,0) = 0
--End: Service Invoice Impact
  
union  
  
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),
DocRef, Creditnote.DocumentDate, Creditnote.Notevalue,    
0 - Creditnote.Balance ,    
datediff(dd, Creditnote.DocumentDate, GetDate()), 'Credit Note'  
from Creditnote, VoucherPrefix
where Creditnote.CustomerID = @CustomerID and    
--Creditnote.DocumentDate between @FromDate and @ToDate and    
Creditnote.Balance > 0 and    
Voucherprefix.TranID = 'CREDIT NOTE' and  
IsNull((Select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0)= IsNull(@BeatID,0)
    
union    
    
select debitnote.debitid, VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar), 
DocRef, Debitnote.DocumentDate, Debitnote.Notevalue, 
Debitnote.Balance ,    
datediff(dd, Debitnote.DocumentDate, GetDate()), 'Debit Note'  
from Debitnote, VoucherPrefix
where Debitnote.CustomerID = @CustomerID and    
--Debitnote.DocumentDate between @FromDate and @ToDate and    
Debitnote.Balance > 0 and    
Voucherprefix.TranID = 'DEBIT NOTE' and  
IsNull((Select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = Debitnote.CustomerID), 0)= IsNull(@BeatID,0)

Union

Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,
Collections.Value, 0 - Collections.Balance, 
DateDiff(dd, Collections.DocumentDate, GetDate()), 'Advance'
From Collections
Where Collections.CustomerID = @CustomerID And
--Collections.DocumentDate Between @FromDate And @ToDate And
Collections.Balance > 0 And
isNull(Collections.BeatID,0) = IsNull(@BeatID,0) --Line Changed isNull in Collection.BeatID is added

Order By "Date", "DocumentID"

