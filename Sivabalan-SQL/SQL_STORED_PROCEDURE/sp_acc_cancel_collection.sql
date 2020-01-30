CREATE PROCEDURE sp_acc_cancel_collection(@CollectionID int,@denominations nvarchar(2000),@CancellationRemarks nvarchar(4000))
as
DECLARE @ADJAMOUNT DECIMAL(18,6)
DECLARE @DOCTYPE DECIMAL(18,6)
DECLARE @DOCID INT
DECLARE @STATUS INT
Declare @Adjustment float
Declare @CreateNew Int
Declare @DocumentValue float
Declare @DocDate Datetime
Declare @OriginalID nVarchar(50)
Declare @Value float
Declare @Ref nVarchar(255)
Declare @GetDate Datetime
Declare @PartyType Int
Declare @PartyID Int
Declare @ExpenseAccount Int

Set @ExpenseAccount = 15 -- Misellaneous account
Set @PartyType=2
Select @PartyID = IsNull(Others,0) From Collections Where DocumentID = @CollectionID

DECLARE COLLECTION_CURSOR CURSOR STATIC FOR
SELECT  collectiondetail.AdjustedAmount ,  collectiondetail.DocumentType ,  collectiondetail.documentid,
isnull(collections.status ,0), ABS(IsNull(CollectionDetail.Adjustment, 0)),
CollectionDetail.DocumentDate, OriginalID, DocumentValue
FROM   collectiondetail, collections WHERE collectiondetail.collectionid = @CollectionID
and  collections.documentid = collectiondetail.collectionid
and (isnull(collections.status,0) & 64) = 0
OPEN COLLECTION_CURSOR
FETCH FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment,
@DocDate, @OriginalID, @DocumentValue
WHILE @@FETCH_STATUS = 0
BEGIN
Set @CreateNew =0
IF @DOCTYPE = 1 -- sales return
Begin
update invoiceabstract set balance = balance +  @ADJAMOUNT + @Adjustment
where invoiceid = dbo.gettrueval(@DOCID)
End
IF @DOCTYPE = 2 -- Credit Note
Begin
If Exists(Select creditid from creditnote where creditid = dbo.gettrueval(@DOCID))
Begin
update creditnote set balance = balance + @ADJAMOUNT + @Adjustment
where creditid = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew=1
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
IF @DOCTYPE = 4 -- ARV
Begin
If Exists(Select Documentid from ARVAbstract where Documentid = dbo.gettrueval(@DOCID))
Begin
update arvabstract set balance = balance + @ADJAMOUNT  + @Adjustment
where Documentid = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew=2
End
End
IF @DOCTYPE = 5-- debit note
Begin
If Exists(Select Debitid from debitnote where Debitid = dbo.gettrueval(@DOCID))
Begin
update debitnote set balance = balance + @ADJAMOUNT  + @Adjustment
where debitid = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew=2
End
End
IF @DOCTYPE = 6 -- APV
Begin
If Exists(Select Documentid from APVAbstract where Documentid = dbo.gettrueval(@DOCID))
Begin
update apvabstract set balance = balance + @ADJAMOUNT  + @Adjustment
where Documentid = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew=1
End
End
IF @DOCTYPE = 7 -- Payments
Begin
If exists(Select DocumentID From Payments Where DocumentID = dbo.gettrueval(@DOCID))
Begin
update payments set balance = balance + @ADJAMOUNT + @Adjustment
where documentid = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew = 2
End
End
IF @DOCTYPE = 8 -- Manual Journal New Reference
Begin
select 1,@DOCID
If Exists(Select NewRefID from ManualJournal where NewRefID = @DOCID)
Begin
Select 2,@DOCID
update manualjournal set balance = balance + @ADJAMOUNT  + @Adjustment
where NewRefID = @DOCID
End
Else
Begin
select 3,@DOCID
Set @CreateNew=1
End
End
IF @DOCTYPE = 9 -- Manual Journal New Reference
Begin
select 4,@DOCID
If Exists(Select NewRefID from ManualJournal where NewRefID = @DOCID)
Begin
select 5,@DOCID
update manualjournal set balance = balance + @ADJAMOUNT  + @Adjustment
where NewRefID = @DOCID
End
Else
Begin
select 6,@DOCID
Set @CreateNew=2
End
End
IF @DOCTYPE = 153 -- Service Invoice Outward
Begin
If Exists(Select InvoiceID from ServiceAbstract Where InvoiceID = dbo.gettrueval(@DOCID))
Begin
Update ServiceAbstract Set Balance = Balance + @ADJAMOUNT  + @Adjustment
Where InvoiceID = dbo.gettrueval(@DOCID)
End
Else
Begin
Set @CreateNew=0
End
End

Set @Value = @ADJAMOUNT + @Adjustment
Set @Ref = @OriginalID + ',' + Cast(@DocDate As nVarchar) + ',' + Cast(@DocumentValue As nVarchar)
-- -- Set @GetDate = getdate()
Set @GetDate = dbo.Sp_Acc_GetOperatingDate(getdate())

If @CreateNew = 1
Begin
exec sp_acc_insert_CreditNote @PartyType, @PartyID, @Value, @GetDate, @Ref, @OriginalID
Update CreditNote Set AccountID =@ExpenseAccount Where IsNull(CreditID,0)=@@Identity
Exec sp_acc_gj_creditnote @@Identity
End
Else If @CreateNew = 2
Begin
exec sp_acc_insert_DebitNote1 @PartyType, @PartyID, @Value, @GetDate, @Ref, 0, @OriginalID
Update DebitNote Set AccountID =@ExpenseAccount Where IsNull(DebitID,0)=@@Identity
Exec sp_acc_gj_debitnote @@Identity
End

FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment,
@DocDate, @OriginalID, @DocumentValue
END
update collections set status = (isnull(status,0) | 192), Balance = 0,
Denomination = @denominations,
Remarks = @CancellationRemarks
where collections.documentid = @collectionid
CLOSE COLLECTION_CURSOR
DEALLOCATE COLLECTION_CURSOR
--status = isnull(status,0) | 192
--status & 64 <> 0 then exit

