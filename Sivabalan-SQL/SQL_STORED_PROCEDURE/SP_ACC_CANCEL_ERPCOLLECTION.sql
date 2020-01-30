CREATE PROCEDURE SP_ACC_CANCEL_ERPCOLLECTION (@CollectionID int,@UserName nvarchar(100))    
as     
DECLARE @ADJAMOUNT DECIMAL(18,6)    
DECLARE @DOCTYPE DECIMAL(18,6)    
DECLARE @DOCID INT    
DECLARE @STATUS INT    
Declare @Adjustment float    
Declare @DocumentValue float    
Declare @DocDate Datetime    
Declare @OriginalID nVarchar(50)    
Declare @Customer nVarchar(20)    
Declare @CreateNew Int    
Declare @PartyType Int    
Declare @Value float    
Declare @Ref nVarchar(255)    
Declare @GetDate Datetime    
Declare @ExpenseAccount Int    
    
Set @ExpenseAccount = 15 -- Misellaneous account    
Set @PartyType=2    
Select @Customer = CustomerID From Collections Where DocumentID = @CollectionID    
Set @PartyType = 0    
DECLARE COLLECTION_CURSOR CURSOR STATIC FOR    
SELECT  collectiondetail.AdjustedAmount ,  collectiondetail.DocumentType ,  collectiondetail.documentid,     
 isnull(collections.status ,0), Abs(IsNull(CollectionDetail.Adjustment, 0)),    
 CollectionDetail.DocumentDate, OriginalID, DocumentValue    
 FROM   collectiondetail, collections WHERE collectiondetail.collectionid = @CollectionID     
 and  collections.documentid = collectiondetail.collectionid    
 and (isnull(collections.status,0) & 64) = 0    
OPEN COLLECTION_CURSOR    
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment,    
@DocDate, @OriginalID, @DocumentValue    
    
WHILE @@FETCH_STATUS = 0    
BEGIN    
 Set @CreateNew  = 0    
 IF @DOCTYPE = 1 OR @DOCTYPE=7-- sales return     
 Begin    
  If exists (Select InvoiceID From InvoiceAbstract Where InvoiceID = dbo.GetTrueVal(@DOCID))    
  Begin    
   update invoiceabstract set balance = balance +  @ADJAMOUNT + @Adjustment     
   where invoiceid = dbo.gettrueval(@DOCID)    
  End    
  Else    
  Begin    
   Set @CreateNew = 1    
  End    
 End    
 IF @DOCTYPE = 2 -- Credit Note     
 Begin    
  If exists (Select CreditID From CreditNote Where CreditID = dbo.gettrueval(@DOCID))    
  Begin    
   update creditnote set balance = balance + @ADJAMOUNT + @Adjustment     
   where creditid = dbo.gettrueval(@DOCID)    
  End    
  Else    
  Begin    
   Set @CreateNew = 1    
  End    
 End    
 IF @DOCTYPE = 3 -- Collection    
 Begin    
  If exists(Select DocumentID From Collections Where DocumentID = dbo.gettrueval(@DOCID))    
  Begin    
   update collections set balance = balance + @ADJAMOUNT + @Adjustment     
   where documentid = dbo.gettrueval(@DOCID)    
  End    
  Else    
  Begin    
   Set @CreateNew = 1    
  End      
 End    
 IF @DOCTYPE = 4 OR @DOCTYPE = 6  -- Invoice & Invopice amendment    
 Begin    
  If exists (Select InvoiceID From InvoiceAbstract Where InvoiceID = dbo.GetTrueVal(@DOCID))    
  Begin    
   update invoiceabstract set balance = balance +  @ADJAMOUNT  + @Adjustment     
   where invoiceid = dbo.gettrueval(@DOCID)    
  End    
  Else    
  Begin    
   Set @CreateNew = 2    
  End    
 End    
 IF @DOCTYPE = 5-- debit note    
 Begin    
  If exists (Select DebitID From DebitNote Where DebitID = dbo.gettrueval(@DOCID))    
  Begin    
   update debitnote set balance = balance + @ADJAMOUNT  + @Adjustment     
   where debitid = dbo.gettrueval(@DOCID)    
  End    
  Else    
  Begin    
   Set @CreateNew = 2    
  End    
 End    
 Set @Value = @ADJAMOUNT + @Adjustment    
 Set @Ref = @OriginalID + ',' + Cast(@DocDate As nVarchar) + ',' + Cast(@DocumentValue As nVarchar)    
 Set @GetDate = dbo.Sp_Acc_GetOperatingDate(getdate())    
  If @CreateNew = 1    
  Begin    
   exec sp_insert_CreditNote @PartyType, @Customer, @Value, @GetDate, @Ref, @OriginalID    
  Update CreditNote Set AccountID =@ExpenseAccount Where IsNull(CreditID,0)=@@Identity    
  --Exec sp_acc_gj_creditnote @@Identity    
  End    
  Else If @CreateNew = 2    
  Begin    
   exec sp_insert_DebitNote @PartyType, @Customer, @Value, @GetDate, @Ref, 0, @OriginalID    
  Update DebitNote Set AccountID =@ExpenseAccount Where IsNull(DebitID,0)=@@Identity    
  --Exec sp_acc_gj_debitnote @@Identity    
  End    
 FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment,    
 @DocDate, @OriginalID, @DocumentValue    
END    
update collections set status = (isnull(status,0) | 192), Balance = 0 ,    CancelUserName =@UserName,CancelDate=GETDATE()
where collections.documentid = @collectionid    
CLOSE COLLECTION_CURSOR     
DEALLOCATE COLLECTION_CURSOR     
