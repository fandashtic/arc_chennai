CREATE procedure spr_list_Beat_OutStanding_Detail( @Customer nvarchar(155))  
as      
Declare @BeatID int    
Declare @CustomerID nvarchar(20)    
Declare @Pos int    
Declare @Length int    
  
Declare @INVOICE NVarchar(50)  
Declare @INVAMENDMENT NVarchar(50)  
Declare @SALESRETURN NVarchar(50)  
Declare @CREDITNOTE NVarchar(50)  
Declare @DEBITNOTE Nvarchar(50)  
Declare @ADVANCE NVarchar(50)  
  
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)  
Set @INVAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)  
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)  
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)  
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)  
Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)  
    
Set @Length = Len(@Customer)    
Set @Pos = CharIndex(N';', @Customer, 1)    
Set @Length = @Length - @Pos    
Set @BeatID = Cast(SubString(@Customer, @Pos + 1, @Length) as int)    
Set @CustomerID = SubString(@Customer, 1, @Pos - 1)    
select InvoiceAbstract.InvoiceID,       
"DocumentID" = Case ISNULL(GSTFlag,0) When 0 then InvPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) ELSE ISNULL(InvoiceAbstract.GSTFullDocID,'') END,      
"Doc Reference"=InvoiceAbstract.DocReference,      
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType      
when 4 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,      
"Balance" = case InvoiceType   
when 4 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,       
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),      
"Invoice Type" = case InvoiceAbstract.InvoiceType      
when 1 then @INVOICE when 3 then @INVAMENDMENT when 4 then @SALESRETURN else N'' end      
from InvoiceAbstract, VoucherPrefix as InvPrefix      
where InvoiceAbstract.CustomerID = @CustomerID and      
InvoiceAbstract.Status & 128 = 0 and        
InvoiceAbstract.InvoiceType in (1, 3, 4) and      
InvoiceAbstract.Balance > 0 and      
InvPrefix.TranID = N'INVOICE' and    
IsNull(InvoiceAbstract.BeatID, 0) = IsNull(@BeatID,0)  
    
union    
    
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),  
DocRef, Creditnote.DocumentDate, Creditnote.Notevalue,      
0 - Creditnote.Balance ,      
datediff(dd, Creditnote.DocumentDate, GetDate()), @CREDITNOTE  
from Creditnote, VoucherPrefix,Customer  
where Creditnote.CustomerID = @CustomerID and       
Customer.DefaultBeatID = @BeatID
and Creditnote.Balance > 0 and      
Voucherprefix.TranID = N'CREDIT NOTE' --and    
--IsNull((Select DefaultBeatID From customer Where CustomerID = CreditNote.CustomerID), 0)= IsNull(@BeatID,0)  
      
union      
      
select debitnote.debitid, VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar),   
DocRef, Debitnote.DocumentDate, Debitnote.Notevalue,   
Debitnote.Balance ,      
datediff(dd, Debitnote.DocumentDate, GetDate()), @DEBITNOTE  
from Debitnote, VoucherPrefix,Customer  
where Debitnote.CustomerID = @CustomerID and 
Customer.CustomerID = Debitnote.CustomerID
and Customer.DefaultBeatID = @BeatID     
--and Debitnote.DocumentDate between @FromDate and @ToDate 
and Debitnote.Balance > 0 and 
IsNull(Debitnote.Status, 0) & 192 = 0   and    
Voucherprefix.TranID = N'DEBIT NOTE' 
--and IsNull((Select DefaultBeatID From customer Where CustomerID = Debitnote.CustomerID), 0)= IsNull(@BeatID,0)  
  
Union  
  
Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,  
Collections.Value, 0 - Collections.Balance,   
DateDiff(dd, Collections.DocumentDate, GetDate()), @ADVANCE  
From Collections  
Where Collections.CustomerID = @CustomerID And  
--Collections.DocumentDate Between @FromDate And @ToDate And  
Collections.Balance > 0 And  
Collections.BeatID = IsNull(@BeatID,0)  
  
Order By "Date", "DocumentID"  
