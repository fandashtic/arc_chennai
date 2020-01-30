CREATE  procedure spr_list_Customer_OutStanding_Detail( @Customer nvarchar(15),                
       @FromDate datetime,                  
       @ToDate datetime)                  
as              
              
Declare @INVOICE NVarchar(50)              
Declare @SALESRETURN NVarchar(50)              
Declare @RETAILINVOICE NVarchar(50)              
Declare @INVOICEAMENDMENT NVarchar(50)              
Declare @SALESRETURNSALEABLE NVarchar(50)              
Declare @SALESRETURNDAMAGE NVarchar(50)              
Declare @CREDITNOTE NVarchar(50)              
Declare @DEBITNOTE NVarchar(50)              
Declare @ADVANCE NVarchar(50)              
              
              
              
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)              
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)              
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)              
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)              
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)              
Set @SALESRETURNDAMAGE = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)              
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)              
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)              
Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)              
              
declare @invtype nvarchar(100)                  
    
select InvoiceAbstract.InvoiceID,                   
"Documentid" =   Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 Then                 
InvPrefix.Prefix                  
+ cast(InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,                  
"Doc Reference"=DocReference,                  
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType                  
when 4 then 0 - InvoiceAbstract.NetValue when 5 then 0 - InvoiceAbstract.NetValue               
when 6 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,                  
"Balance" = case InvoiceType                   
     when 4 then 0 - InvoiceAbstract.Balance when 5 then 0 - InvoiceAbstract.Balance              
 when 6 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,             
"Cheque on Hand (%c)" =  (Select  Sum(    
Case When isnull(C.Realised,0) =3 Then      
(dbo.mERP_fn_getCollBalance_ITC_Rpt(CD.DocumentID, CD.DocumentType,@Todate,C.DocumentiD,GetDate()))      
Else      
 (Case When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then    
 (isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))    
 When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) >= isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then 0    
 Else    
 (isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))end)    
End)    
    
 from Collections C,CollectionDetail CD,ChequeCollDetails CCD Where               
C.DocumentID = CD.CollectionID and C.CustomerID = @Customer And InvoiceAbstract.InvoiceID = CD.DocumentID And CD.DocumentType = 4     
And C.DocumentDate between @fromdate and @todate    
And CD.Documentid =CCD.Documentid     
And CCD.CollectionID = C.DocumentiD    
and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(2)),         
             
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),                  
"Doc Type" = case InvoiceAbstract.InvoiceType                  
when 1 then @INVOICE when 2 then @RETAILINVOICE when 3 then @INVOICEAMENDMENT              
when 4 then @SALESRETURN when 5 then @SALESRETURNSALEABLE when 6 then @SALESRETURNDAMAGE else N'' end              
from InvoiceAbstract, VoucherPrefix as InvPrefix                  
where InvoiceAbstract.CustomerID = @Customer and                  
InvoiceAbstract.Status & 128 = 0 and                  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and    
InvoiceAbstract.InvoiceType in (1, 2, 3) and  
InvoiceAbstract.Balance >= 0 and                  
InvPrefix.TranID = N'INVOICE'     
    
Union    
select InvoiceAbstract.InvoiceID,                   
"Documentid" = Case ISNULL(InvoiceAbstract.GSTFlag,0) when 0 then                  
InvPrefix.Prefix                  
+ cast(InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,                  
"Doc Reference"=DocReference,                  
"Date" = InvoiceAbstract.InvoiceDate, "Amount" = case InvoiceType                  
when 4 then 0 - InvoiceAbstract.NetValue when 5 then 0 - InvoiceAbstract.NetValue               
when 6 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,                  
"Balance" = case InvoiceType                   
     when 4 then 0 - InvoiceAbstract.Balance when 5 then 0 - InvoiceAbstract.Balance              
 when 6 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,             
"Cheque on Hand (%c)" =  0,                  
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),                  
"Doc Type" = case InvoiceAbstract.InvoiceType                  
when 1 then @INVOICE when 2 then @RETAILINVOICE when 3 then @INVOICEAMENDMENT              
when 4 then @SALESRETURN when 5 then @SALESRETURNSALEABLE when 6 then @SALESRETURNDAMAGE else N'' end              
from InvoiceAbstract, VoucherPrefix as InvPrefix                  
where InvoiceAbstract.CustomerID = @Customer and                  
InvoiceAbstract.Status & 128 = 0 and                  
InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and                  
InvoiceAbstract.InvoiceType in (4, 5, 6) and                  
InvoiceAbstract.Balance >= 0 and                  
InvPrefix.TranID = N'SALES RETURN'     
    
union                  
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),                 
DocRef,                
Creditnote.DocumentDate, Creditnote.Notevalue,                  
0 - Creditnote.Balance ,0 ,                 
datediff(dd, Creditnote.DocumentDate, GetDate()), @CREDITNOTE              
from Creditnote, VoucherPrefix                   
where Creditnote.CustomerID = @Customer and                  
Creditnote.DocumentDate between @FromDate and @ToDate and                  
Creditnote.Balance > 0 and                  
Voucherprefix.TranID = N'CREDIT NOTE'     
                  
union                  
                  
select debitnote.debitid,  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar),                 
DocRef,                 
Debitnote.DocumentDate,                  
Debitnote.Notevalue,                  
Debitnote.Balance ,(Select Sum( Distinct    
Case When isnull(C.Realised,0) =3 Then      
(dbo.mERP_fn_getCollBalance_ITC_Rpt(CD.DocumentID, CD.DocumentType,@Todate,C.Documentid,GetDate()))      
Else      
 (Case When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) < isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then    
 (isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))    
 When isnull(CCd.ChqStatus,0) = 1 And dbo.stripdatefromtime(@todate) >= isnull(dbo.stripdatefromtime(CCD.Realisedate),getdate()) Then 0    
 Else    
 (isnull(isnull(AdjustedAmount,0),0)-isnull(isnull(DocAdjustAmount,0),0))end)    
End )     
from Collections C,CollectionDetail CD,ChequeCollDetails CCD Where               
C.DocumentID = CD.CollectionID and C.CustomerID = @Customer And DebitNote.DebitID = CD.DocumentID And CD.DocumentType =5     
And CCD.CollectionID = C.Documentid    
And CCd.Documentid = CD.Documentid    
and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(2)),                   
    
    
    
datediff(dd, Debitnote.DocumentDate, GetDate()), @DEBITNOTE              
from Debitnote, VoucherPrefix                   
where Debitnote.CustomerID = @Customer and                  
isnull(status,0) & 192 = 0 And    
Debitnote.DocumentDate between @FromDate and @ToDate and                  
Debitnote.Balance >= 0 and            
isnull(flag,0)<> 2 and      
Voucherprefix.TranID = N'DEBIT NOTE'                 
union                
                
Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,                
Collections.Value, 0 - Collections.Balance,isnull((Select sum(C.Balance) from Collections C Where               
C.DocumentID = Collections.DocumentID  and C.CustomerID = @Customer and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(C.realised,0) not in(1,2,4,5)),0),                 
DateDiff(dd, Collections.DocumentDate, GetDate()), @ADVANCE              
From Collections                
Where Collections.CustomerID = @Customer And                
Collections.DocumentDate Between @FromDate And @ToDate And                
Collections.Balance > 0                
Order By "Date", "Documentid" 
