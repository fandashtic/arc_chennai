Create procedure sp_list_collections_ITC(@CustomerID nvarchar(15), @SalesmanID int, @BeatID int)                
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
                
Create Table #tempCollection([Document ID] nvarchar(255),[DocumentDate] datetime,Netvalue decimal(18,6),                
Balance decimal(18,6),InvoiceID int,Type int,[Desc] nvarchar(500),AdditionalDiscount decimal(18,6),DocReference nvarchar(500),DisableEdit int,ChequeOnHand decimal(18,6))                
                
Insert into #tempCollection([Document ID],[DocumentDate],Netvalue,                
Balance,InvoiceID,Type,[Desc],AdditionalDiscount,DocReference,ChequeonHand)  
 (     
             
select "DocumentID" = 
Case IsNULL(GSTFlag ,0)
When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar)                        
Else
	IsNULL(GSTFullDocID,'')
End,

"DocumentDate" = InvoiceDate, NetValue, Balance,                     
InvoiceID, "Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,                    
"Desc" = 'Sales Return',   
AdditionalDiscount, DocReference,0                        
from invoiceabstract, VoucherPrefix                        
where  ISNULL(Balance, 0) > 0 and 
InvoiceType in(4,5,6) and                 
IsNull(Status, 0) & 128 = 0 and                        
invoiceabstract.InvoiceID Not In ( Select InvoiceID  from tbl_merp_DSOStransfer ) and   
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and                   
IsNull(BeatID,0) In (Select BeatID From #TBeat) and                     
VoucherPrefix.TranID = 'SALES RETURN'                        
  
Union  
  
select "DocumentID" = 
Case IsNULL(GSTFlag ,0)
When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar)                        
Else
	IsNULL(GSTFullDocID,'')
End,

"DocumentDate" = InvoiceDate, NetValue, Balance,                     
InvoiceAbstract.InvoiceID, "Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,                    
"Desc" = 'Sales Return',   
AdditionalDiscount, DocReference,0                        
from invoiceabstract, VoucherPrefix, tbl_mERP_DSOSTransfer DSOSTrfr                        
where ISNULL(Balance, 0) > 0  and
InvoiceType in(4,5,6)    
and InvoiceAbstract.InvoiceID = DSOSTrfr.InvoiceID  
and IsNull(Status, 0) & 128 = 0 and                        
CustomerID = @CustomerID and IsNull(DSOSTrfr.MappedSalesmanID,0) In (Select SalesmanID From #TSalesman) and                   
IsNull(DSOSTrfr.MappedBeatID,0) In (Select BeatID From #TBeat) and                                        
VoucherPrefix.TranID = 'SALES RETURN'                        
  
                     
union                        
                        
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),                         
"DocumentDate" = DocumentDate,                         
NoteValue, Balance, CreditID, "Type" = 2,                  
"Desc" =Case IsNULL(Flag,0)                  
When 7 then                  
'Sales Return'                  
When 8 then                  
'Advance Collection'                  
Else                  
'Credit Note'                  
end, 0, DocRef,0                        
from CreditNote, VoucherPrefix                        
where Balance > 0 and                        
CustomerID = @CustomerID and                        
VoucherPrefix.TranID = 'CREDIT NOTE'                       
and CreditNote.Flag In (0,1)  
and creditid not in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)
/* CLO Changes*/
union                        
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),                         
"DocumentDate" = DocumentDate,                         
NoteValue, Balance, CreditID, "Type" = 2,                  
"Desc" =Case IsNULL(Flag,0)                  
When 7 then                  
'Sales Return'                  
When 8 then                  
'Advance Collection'                  
Else                  
'Credit Note'                  
end, 0, DocRef,0                        
from CreditNote, VoucherPrefix                        
where Balance > 0 and                        
CustomerID = @CustomerID and                        
VoucherPrefix.TranID = 'GIFT VOUCHER' 
and CreditNote.Flag =1 
and creditid in (select isnull(creditID,0) from CLOCrnote where isnull(isgenerated,0)=1)

union                        
                        
select "DocumentID" = FullDocID,                         
"DocumentDate" = DocumentDate, Value,                         
Balance, DocumentID, "Type" = 3, "Desc" = 'Collections', 0, Null,0                        
from Collections, VoucherPrefix                        
where Balance > 0 and                        
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and                     
IsNull(BeatID,0) In (Select BeatID From #TBeat) and                   
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
Balance, InvoiceID,   
"Type" = case InvoiceType                       
 when 1 then   4                        
 when 2 then   6                        
 when 3 then   4 end,                        
"Desc" =case InvoiceType                        
when 1 then                        
  'Invoice'                        
when 2 then                        
  'Retail Invoice'                        
when 3 then                        
  'Invoice Amd'                        
end,                  
AdditionalDiscount, DocReference,(Select Case When MAx(isnull(C.Realised,0)) =3 Then   
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))   
Else   
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end   
from Collections C, CollectionDetail CD                
Where CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1                 
and IsNull(c.Realised, 0) Not In (1, 2))                          
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix, VoucherPrefix as RPrefix                  
where ISNULL(InvoiceAbstract.Balance, 0) >= 0 And     
IsNull(Status, 0) & 128 = 0 and  
InvoiceType in (1, 3, 2) and                        
InvoiceAbstract.InvoiceID Not In ( Select InvoiceID from tbl_merp_DSOStransfer ) and   
CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID From #TSalesman) and                   
IsNull(BeatID,0) In (Select BeatID From #TBeat) and                     
VoucherPrefix.TranID = 'INVOICE' and                        
InvPrefix.TranID = 'INVOICE AMENDMENT' And                  
RPrefix.TranID = 'RETAIL INVOICE'                  
  
Union
  
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
Balance, InvoiceAbstract.InvoiceID, "Type" = case InvoiceType                       
 when 1 then   4                        
 when 2 then   6                        
 when 3 then   4 end,                        
"Desc" =case InvoiceType                        
when 1 then                        
  'Invoice'                        
when 2 then                        
  'Retail Invoice'                        
when 3 then                        
  'Invoice Amd'                        
end,                  
AdditionalDiscount, DocReference,(Select Case When MAx(isnull(C.Realised,0)) =3 Then   
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))   
Else   
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end   
from Collections C, CollectionDetail CD                
Where CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1                 
and IsNull(c.Realised, 0) Not In (1, 2))  
                          
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix, VoucherPrefix as RPrefix                  
, tbl_mERP_DSOSTransfer DSOSTrfr  
where   ISNULL(InvoiceAbstract.Balance, 0) >= 0 And  
InvoiceAbstract.InvoiceID = DSOSTrfr.InvoiceID and  
InvoiceType in (1, 3, 2) and                        
IsNull(Status, 0) & 128 = 0 and                        
CustomerID = @CustomerID and IsNull(DSOSTrfr.MappedSalesmanID,0) In (Select SalesmanID From #TSalesman) and                   
IsNull(DSOSTrfr.MappedBeatID,0) In (Select BeatID From #TBeat) and                     
VoucherPrefix.TranID = 'INVOICE' and                        
InvPrefix.TranID = 'INVOICE AMENDMENT' And                  
RPrefix.TranID = 'RETAIL INVOICE'                  
  
  
union              
                        
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),                         
"DocumentDate" = DocumentDate, NoteValue, Balance, DebitID, "Type" = 5,                         
"Desc" = case Flag                        
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
end, 0, DocRef, (Select Case When MAx(isnull(C.Realised,0)) =3 Then   
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))   
Else   
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end   
from Collections C, CollectionDetail CD                
Where CD.DocumentID = DebitNote.debitID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1                 
and IsNull(c.Realised, 0) Not In (1, 2))                   
from DebitNote, VoucherPrefix                        
where Balance >= 0 and                         
Isnull(DebitNote.Status ,0) <> 192 And
CustomerID = @CustomerID and                         
VoucherPrefix.TranID = 'DEBIT NOTE')                
  
  
  
      
          
 Declare getAllID Cursor For Select Distinct T.InvoiceID from #tempCollection T,ChequeCollDetails CD             
 Where T.Type in(4) And T.invoiceID = CD.DocumentID and CD.DocumentType in(4) And isnull(CD.debitID,0)<> 0            
Open getAllID              
Fetch From getAllID into @InvID             
While @@fetch_status = 0              
 BEGIN              
  Insert into #tempdebitID             
  Select isnull(CD.DebitID,0) From ChequeCollDetails CD, collections C Where C.CustomerID = @CustomerID And CD.DocumentID=@InvID               
  And C.DocumentID = CD.CollectionID and CD.DocumentType in (4) And isnull(C.Status,0) & 192 = 0            
  Update #tempCollection Set Balance = Balance + IsNull((Select sum(Balance) from debitnote Where debitid in(select DebitID from #tempDebitID)),0), DisableEdit=1 Where InvoiceID = @InvID              
          
  If (Select isnull(PaymentDetails,0) from invoiceabstract where Invoiceid = @InvID and isnull(PaymentMode,0) = 2 ) <> 0          
  Update #tempCollection Set [Desc]='Inv cheque Bounced' Where Invoiceid = @InvID and [Type] = 4          
          
  Delete from #tempCollection Where InvoiceID in(Select debitid from #tempdebitID)            
  Fetch Next From getAllID into @InvID                
  Truncate Table #tempdebitID            
 END              
              
Close getAllID              
Deallocate getAllID              
       
           
 Declare getAllDebitID Cursor For Select  Distinct T.InvoiceID from #tempCollection T,ChequeCollDetails CD             
 Where T.Type in(5) And T.invoiceID = CD.DocumentID and CD.DocumentType in(5) And isnull(CD.debitID,0)<> 0            
Open getAllDebitID              
Fetch From getAllDebitID into @InvID             
While @@fetch_status = 0              
 BEGIN              
  Insert into #tempdebitID             
  Select isnull(CD.DebitID,0) From ChequeCollDetails CD, collections C Where C.CustomerID = @CustomerID And CD.DocumentID=@InvID               
  And C.DocumentID = CD.CollectionID and CD.DocumentType in (5) And isnull(C.Status,0) & 192 = 0            
            
  Update #tempCollection Set Balance = Balance + IsNull((Select sum(Balance) from debitnote Where debitid in(select DebitID from #tempDebitID)),0), DisableEdit = 1 Where InvoiceID = @InvID              
  Delete from #tempCollection Where InvoiceID in(Select debitid from #tempdebitID)            
            
  Fetch Next From getAllDebitID into @InvID                
  Truncate Table #tempdebitID            
 END              
              
Close getAllDebitID              
Deallocate getAllDebitID              
                
Select * from #tempCollection where Balance > 0 Order by DocumentDate              
                
Drop Table #tempCollection                
Drop Table #TSalesman                  
Drop Table #TBeat                  
Drop Table #tempdebitID     
