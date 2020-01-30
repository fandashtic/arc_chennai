Create procedure sp_list_Amendcollections_ITC(@CustomerID nvarchar(15),            
       @CollectionID int, @SalesmanID int, @BeatID int)            
as            
      
Declare @DrID as int              
Declare @InvID as int        
        
Create Table #TSalesman (SalesmanID int)        
Create Table #TBeat (BeatID int)        
Create Table #tempDebitID(debitid int)          
      
If @SalesmanID=0        
Begin        
 Insert Into #TSalesman Values (0)        
 Insert Into #TSalesman Select SalesmanID From Salesman        
End        
Else        
 Insert Into #TSalesman Select SalesmanID From Salesman Where SalesmanID=@SalesmanID        
          
If @BeatID=0        
Begin        
 Insert Into #TBeat Values (0)        
 Insert Into #TBeat Select BeatID From Beat        
End        
Else        
 Insert Into #TBeat Select BeatID From Beat Where BeatID=@BeatID        
      
Create Table #tempCollection([DocumentID] nvarchar(255),[DocumentDate] datetime,Netvalue decimal(18,6),            
Balance decimal(18,6),InvoiceID int,Type int,[Desc] nvarchar(500),AdditionalDiscount decimal(18,6),DocReference nvarchar(500),DisableEdit int,ChqinHandValue decimal(18,6))            
        
Insert into #tempCollection([DocumentID],[DocumentDate],Netvalue,            
Balance,InvoiceID,Type,[Desc],AdditionalDiscount,DocReference,ChqinHandValue) (         
select 
--"DocumentID" = VoucherPrefix.Prefix + CAST(DocumentID as nvarchar),             
"DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'''') End,
"DocumentDate" = InvoiceDate,             
NetValue, Balance, InvoiceID, "Type" = 1, dbo.LookupDictionaryItem(N'Sales Return', default),       
AdditionalDiscount, DocReference,0            
from invoiceabstract, VoucherPrefix            
where InvoiceType = 4 and            
IsNull(Status, 0) & 128 = 0 and            
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and         
IsNull(BeatID,0) In (Select BeatID From #TBeat) and            
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
End, Default), 0, DocRef,0            
from CreditNote, VoucherPrefix            
where CustomerID = @CustomerID and            
Balance > 0 and 
VoucherPrefix.TranID = 'CREDIT NOTE' and            
CreditID Not in (Select DocumentID From CollectionDetail             
Where CollectionID = @CollectionID And DocumentType = 2)            
            
union            
            
select "DocumentID" = FullDocID,             
"DocumentDate" = DocumentDate, Value,             
Balance, DocumentID, "Type" = 3, dbo.LookupDictionaryItem(N'Collections', Default) ,0, Null,0            
from Collections, VoucherPrefix            
where Balance > 0 and            
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and           
IsNull(BeatID,0) In (Select BeatID From #TBeat) and         
(IsNull(Status, 0) & 192) = 0 And -- Cancelled collections            
VoucherPrefix.TranID = 'COLLECTIONS' and            
DocumentID Not in (Select DocumentID From CollectionDetail             
Where CollectionID = @CollectionID And DocumentType = 3) And        
DocumentID Not in (Select @CollectionID)            
            
union            
        
select "DocumentID" = Case IsNULL(GSTFlag ,0) When 0 then 
case InvoiceType            
when 1 then            
  VoucherPrefix.Prefix             
when 2 then            
  VoucherPrefix.Prefix             
when 3 then            
  InvPrefix.Prefix            
end            
+ CAST(DocumentID as nvarchar)
Else IsNULL(GSTFullDocID,'''') End,       
"DocumentDate" = InvoiceDate, NetValue,             
Balance, InvoiceID, "Type" = 4,            
dbo.LookupDictionaryItem(case InvoiceType            
when 1 then            
  N'Invoice'          when 2 then            
  N'Retail Invoice'            
when 3 then            
  N'Invoice Amd'            
end, Default),        
AdditionalDiscount, DocReference,(Select Case When MAx(isnull(C.Realised,0)) =3 Then 
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType))) 
Else 
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end from Collections C, CollectionDetail CD        
Where Cd.DocumentType = 4 And CD.DocumentID = InvoiceAbstract.InvoiceID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1         
and IsNull(c.Realised, 0) Not In (1, 2))                 
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix            
where InvoiceType in (1, 3 ,2) and            
IsNull(Status, 0) & 128 = 0 and            
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and         
IsNull(BeatID,0) In (Select BeatID From #TBeat) and            
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
end, Default), 0, DocRef,(Select Case When MAx(isnull(C.Realised,0)) =3 Then 
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType))) 
Else 
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end  from Collections C, CollectionDetail CD        
Where Cd.DocumentType = 5 and CD.DocumentID = DebitNote.DebitID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1                     
and IsNull(c.Realised, 0) Not In (1, 2))              
from DebitNote, VoucherPrefix            
where Balance > 0 and      
isnull(Flag,0) <> 2 And      
CustomerID = @CustomerID and             
VoucherPrefix.TranID = 'DEBIT NOTE' and            
DebitID Not in (Select DocumentID From CollectionDetail             
Where CollectionID = @CollectionID And DocumentType = 5))            
        
      
 Declare getAllID Cursor For Select Distinct T.InvoiceID from #tempCollection T,ChequeCollDetails CD         
 Where T.Type in(4) And T.invoiceID = CD.DocumentID and CD.DocumentType in(4) And isnull(CD.debitID,0)<> 0        
Open getAllID          
Fetch From getAllID into @InvID         
While @@fetch_status = 0          
 BEGIN          
  Insert into #tempdebitID         
  Select isnull(CD.DebitID,0) From ChequeCollDetails CD, collections C Where C.CustomerID = @CustomerID And CD.DocumentID=@InvID           
  And C.DocumentID = CD.CollectionID and CD.DocumentType in (4) And isnull(C.Status,0) & 192 = 0        
        
  Update #tempCollection Set Balance = Balance + (Select sum(Balance) from debitnote Where debitid in(select DebitID from #tempDebitID)),DisableEdit =1,[Desc]='Inv Chq Bounced' Where InvoiceID = @InvID          
  Delete from #tempCollection Where InvoiceID in(Select debitid from #tempdebitID)        
        
  Fetch Next From getAllID into @InvID            
  Truncate Table #tempdebitID        
 END          
          
Close getAllID          
Deallocate getAllID          
        
        
 Declare getAllDebitID Cursor For Select Distinct T.InvoiceID from #tempCollection T,ChequeCollDetails CD         
 Where T.Type in(5) And T.invoiceID = CD.DocumentID and CD.DocumentType in(5) And isnull(CD.debitID,0)<> 0        
Open getAllDebitID          
Fetch From getAllDebitID into @InvID         
While @@fetch_status = 0          
 BEGIN          
  Insert into #tempdebitID         
  Select isnull(CD.DebitID,0) From ChequeCollDetails CD, collections C Where C.CustomerID = @CustomerID And CD.DocumentID=@InvID           
  And C.DocumentID = CD.CollectionID and CD.DocumentType in (5) And isnull(C.Status,0) & 192 = 0        
        
  Update #tempCollection Set Balance = Balance + (Select sum(Balance) from debitnote Where debitid in(select DebitID from #tempDebitID)),DisableEdit = 1,[Desc] = 'Debit Note Chq Bounced' Where InvoiceID = @InvID          
  Delete from #tempCollection Where InvoiceID in(Select debitid from #tempdebitID)        
        
  Fetch Next From getAllDebitID into @InvID            
  Truncate Table #tempdebitID        
 END          
          
Close getAllDebitID          
Deallocate getAllDebitID          
            
Select * from #tempCollection      
      
Drop Table #TSalesman        
Drop Table #TBeat        

