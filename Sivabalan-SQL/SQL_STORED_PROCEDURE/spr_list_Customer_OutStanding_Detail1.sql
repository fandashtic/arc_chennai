Create procedure spr_list_Customer_OutStanding_Detail1( @Customer nvarchar(15),  
						       @FromDate datetime,  
						       @ToDate datetime)  
as  

Declare @INVOICE NVarchar(50)
Declare @SALESRETURN NVarchar(50)
Declare @INVOICEAMENDMENT NVarchar(50)
Declare @CREDITNOTE NVarchar(50)
Declare @DEBITNOTE NVarchar(50)




Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)



select InvoiceAbstract.InvoiceID,   
"DocumentID" =   
InvPrefix.Prefix  
+ cast(InvoiceAbstract.DocumentID as nvarchar),  
"Doc Reference"=DocReference,  
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType  
when 4 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,  
"Balance" = case InvoiceType   
     when 4 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,   
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),  
"Doc Type" = case InvoiceAbstract.InvoiceType  
when 1 then @INVOICE when 2 then @INVOICEAMENDMENT when 4 then @SALESRETURN else N'' end  
from InvoiceAbstract, VoucherPrefix as InvPrefix  
where InvoiceAbstract.CustomerID = @Customer and  
InvoiceAbstract.Status & 128 = 0 and  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and  
InvoiceAbstract.InvoiceType in (1, 3, 4) and  
InvoiceAbstract.Balance > 0 and  
InvPrefix.TranID = N'INVOICE'  
  
union  
  
select creditnote.creditid,  
"DocumentID" =  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),"Doc Reference" = NULL,
"Date" =  Creditnote.DocumentDate, 
"Amount" = Creditnote.Notevalue,  
"Balance" =  Creditnote.Balance ,  
"Due days" = datediff(dd, Creditnote.DocumentDate, GetDate()), 
"Doc Type" = @CREDITNOTE
from Creditnote, VoucherPrefix   
where Creditnote.CustomerID = @Customer and  
Creditnote.DocumentDate between @FromDate and @ToDate and  
Creditnote.Balance > 0 and  
Voucherprefix.TranID = N'CREDIT NOTE'  
  
union  
  
select debitnote.debitid,  
"DocumentID" =  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar), 
"Doc Reference" = NULL , 
"Date" =  Debitnote.DocumentDate,  
"Amount" =   Debitnote.Notevalue,  
"Balance" = Debitnote.Balance ,  
"Due days" = datediff(dd, Debitnote.DocumentDate, GetDate()), 
"Doc Type" = @DEBITNOTE
from Debitnote, VoucherPrefix   
where Debitnote.CustomerID = @Customer and  
Debitnote.DocumentDate between @FromDate and @ToDate and  
Debitnote.Balance > 0 and  
Voucherprefix.TranID = N'DEBIT NOTE'  

