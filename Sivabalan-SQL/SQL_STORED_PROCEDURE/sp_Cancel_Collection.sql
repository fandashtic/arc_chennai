CREATE PROCEDURE sp_Cancel_Collection (@CollectionID int)
as
DECLARE @ADJAMOUNT Decimal(18,6)
DECLARE @DOCTYPE Decimal(18,6)
DECLARE @DOCID INT
DECLARE @STATUS INT
Declare @Adjustment Decimal(18,6)
Declare @DocumentValue Decimal(18,6)
Declare @DocDate Datetime
Declare @OriginalID nvarchar(50)
Declare @Customer nvarchar(20)
Declare @CreateNew Int
Declare @PartyType Int
Declare @Value Decimal(18,6)
Declare @Ref nvarchar(255)
Declare @GetDate Datetime


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
IF @DOCTYPE = 1 or @DOCTYPE=7 -- sales return
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
where creditid = dbo.gettrueval(@DOCID) And Isnull(FreeSKUFlag,0) = 0
If (Select Count(*) from CreditNote where creditid = dbo.gettrueval(@DOCID) And Isnull(FreeSKUFlag,0) = 1) > 0
Begin
Declare @DocumentID Int
Declare @Cancel_Date DateTime
Set @DocumentID = dbo.gettrueval(@DOCID)
Select @Cancel_Date = DocumentDate FROM collectiondetail Where collectionid = @CollectionID
--Select @DocumentID,@Cancel_Date
--Select @ADJAMOUNT , @DOCTYPE , @DOCID, @STATUS, @Adjustment,@DocDate, @OriginalID, @DocumentValue
exec sp_cancel_CreditNote_SplSKU @DocumentID,'','',@Cancel_Date
exec sp_acc_gj_creditnotecancel @DocumentID,NULL
End
End
Else
Begin
Set @CreateNew = 1
End
End

IF @DOCTYPE = 10
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

--GiftVoucher Status changed after invoice cancelled
Update GiftvoucherDetail Set Status = 2 , AmountRedeemed = AmountRedeemed - @ADJAMOUNT
Where SerialNo = (Select SerialNo From IssueGiftVoucher Where CollectionID = dbo.gettrueval(@DOCID))

End
Else
Begin
Set @CreateNew = 1
End
End

IF @DOCTYPE = 4 or @DOCTYPE=6  -- Invoice & Invopice amendment  & RetailInvoice & amendment
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
IF @DOCTYPE = 5  -- debit note
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
Set @Ref = @OriginalID + ',' + Cast(@DocDate As nvarchar) + ',' + Cast(@DocumentValue As nvarchar)
Set @GetDate = GetDate()

If @CreateNew = 1
Begin
exec sp_insert_CreditNote @PartyType, @Customer, @Value, @GetDate, @Ref, @OriginalID
End
Else If @CreateNew = 2
Begin
exec sp_insert_DebitNote @PartyType, @Customer, @Value, @GetDate, @Ref, 0, @OriginalID
End
FETCH NEXT FROM COLLECTION_CURSOR INTO  @ADJAMOUNT , @DOCTYPE , @DOCID,  @STATUS, @Adjustment,
@DocDate, @OriginalID, @DocumentValue
END
update collections set status = (isnull(status,0) | 192), Balance = 0
where collections.documentid = @collectionid
CLOSE COLLECTION_CURSOR
DEALLOCATE COLLECTION_CURSOR

