CREATE Procedure sp_get_AmendedCollection (@CollectionID Int)          
As        
         
            
Declare @InvID int            
Declare @CustomerID nvarchar(250)            
Declare @DID  int  
Declare @Dtype int  
Select @CustomerID = CustomerID from Collections Where DocumentID = @CollectionID            
            
Create Table #tempDebitID(debitid int)            
            
Create Table #tempCollection (OriginalID nvarchar(500),DocumentDate datetime,DocumentValue decimal(18,6),AdjustedAmt decimal(18,6),            
DocumentType int,extracollection decimal(18,6),DocRef nvarchar(500),Adjustment decimal(18,6),DocumentID int,DocType nvarchar(500),            
NetValue Decimal(18,6),AdditionalDiscount decimal(18,6),Discount decimal(18,6),DisableEdit int,ChequeOnHand decimal(18,6),Flag int)            
            
Insert into #tempCollection (OriginalID,DocumentDate,DocumentValue,AdjustedAmt,            
DocumentType,extracollection,DocRef,Adjustment,DocumentID,DocType,            
NetValue,AdditionalDiscount,Discount,ChequeOnHand,Flag)            
            
(Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,             
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,            
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,            
CollectionDetail.DocRef, CollectionDetail.Adjustment,             
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Sales Return', Default),             
InvoiceAbstract.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,            
InvoiceAbstract.AdditionalDiscount,ISnull(Collectiondetail.Discount,0),0,0            
From CollectionDetail, InvoiceAbstract            
Where CollectionDetail.CollectionID = @CollectionID And            
CollectionDetail.DocumentType in(1,7) And            
InvoiceAbstract.InvoiceID = CollectionDetail.DocumentID            
            
Union            
            
Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,             
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,            
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,            
CollectionDetail.DocRef, CollectionDetail.Adjustment,             
CollectionDetail.DocumentID,             
dbo.LookupDictionaryItem(Case IsNULL(CreditNote.Flag,0)            
When 7 then            
'Sales Return'            
When 8 then            
'Advance Collection'            
Else            
'Credit Note'            
End, Default),            
CreditNote.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,            
Null,ISnull(Collectiondetail.Discount,0),0,0            
From CollectionDetail, CreditNote            
Where CollectionDetail.CollectionID = @CollectionID And            
CollectionDetail.DocumentType = 2 And            
CreditNote.CreditID = CollectionDetail.DocumentID            
            
Union            
            
Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,             
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,            
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,            
CollectionDetail.DocRef, CollectionDetail.Adjustment,             
CollectionDetail.DocumentID, dbo.LookupDictionaryItem('Collections', Default),            
Collections.Balance + CollectionDetail.AdjustedAmount + CollectionDetail.ExtraCollection + CollectionDetail.Adjustment,            
Null,ISnull(Collectiondetail.Discount,0),0,0            
From CollectionDetail, Collections            
Where CollectionDetail.CollectionID = @CollectionID And            
CollectionDetail.DocumentType = 3 And            
Collections.DocumentID = CollectionDetail.DocumentID            
            
Union            
     
Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,             
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,            
CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,            
CollectionDetail.DocRef, CollectionDetail.Adjustment,             
CollectionDetail.DocumentID,            
dbo.LookupDictionaryItem(Case InvoiceAbstract.InvoiceType            
When 1 Then            
'Invoice'            
When 2 Then            
'Retail Invoice'            
When 3 Then            
'Invoice Amd'           
End, Default),            
InvoiceAbstract.Balance + CollectionDetail.AdjustedAmount + Abs(CollectionDetail.Adjustment),         
Isnull(InvoiceAbstract.AdditionalDiscount,0) , Isnull(Collectiondetail.Discount,0),(Select Case When MAx(isnull(C.Realised,0)) =3 Then 
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType))) 
Else 
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end  from Collections C, CollectionDetail CD              
Where CD.DocumentID = InvoiceAbstract.InvoiceID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1               
and IsNull(c.Realised, 0) Not In (1, 2)),0               
From CollectionDetail, InvoiceAbstract            
Where CollectionDetail.CollectionID = @CollectionID And            
CollectionDetail.DocumentType in(4,6) And            
InvoiceAbstract.InvoiceID = CollectionDetail.DocumentID            
            
Union            
            
Select CollectionDetail.OriginalID, CollectionDetail.DocumentDate,             
CollectionDetail.DocumentValue, CollectionDetail.AdjustedAmount,  CollectionDetail.DocumentType, CollectionDetail.ExtraCollection,            
CollectionDetail.DocRef, CollectionDetail.Adjustment,             
CollectionDetail.DocumentID,            
dbo.LookupDictionaryItem(Case IsNULL(DebitNote.Flag,0)            
When 5 then             
'Invoice'            
Else            
'Debit Note'            
End, Default),            
DebitNote.Balance + CollectionDetail.AdjustedAmount + Abs(CollectionDetail.Adjustment),            
NULL,ISnull(Collectiondetail.Discount,0),(Select Case When MAx(isnull(C.Realised,0)) =3 Then 
(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType))) 
Else 
(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end from Collections C, CollectionDetail CD              
Where CD.DocumentID = DebitNote.DebitID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1                           
and IsNull(c.Realised, 0) Not In (1, 2)),isnull(DebitNote.Flag,0)               
From CollectionDetail, DebitNote            
Where CollectionDetail.CollectionID = @CollectionID And            
CollectionDetail.DocumentType = 5 And            
DebitNote.DebitID = CollectionDetail.DocumentID)            
       
  
  
 Declare getAllID Cursor For Select Distinct T.DocumentID,CD.DocumentID,Cd.DocumentType from #tempCollection T,ChequeCollDetails CD       
 Where T.DocumentType in(5) And T.DocumentID = CD.DebitID and isnull(CD.debitID,0)<> 0      
Open getAllID        
Fetch From getAllID into @InvID ,@dID,@DType     
While @@fetch_status = 0        
 BEGIN        
  Update  #tempCollection Set AdjustedAmt = AdjustedAmt + (Select sum(Adjustedamt) from #tempCollection Where documentID = @InvID and documenttype = 5),  
  NetValue = NetValue +  (Select sum(NetValue) from #tempCollection Where documentID = @InvID and documenttype = 5)  
  Where DocumentID= @dID and DocumentType =@dType  
Fetch Next From getAllID into @InvID ,@dID,@DType  
 END        
        
Close getAllID        
Deallocate getAllID        
      
Select * from #tempCollection Where Flag <> 2           
Drop Table #tempCollection            
