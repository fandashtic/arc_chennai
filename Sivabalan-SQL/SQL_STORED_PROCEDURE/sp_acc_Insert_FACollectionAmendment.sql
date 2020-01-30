CREATE procedure sp_acc_Insert_FACollectionAmendment(@DocumentDate datetime,
@Value float, @Balance float, @PaymentMode integer, @ChequeNumber integer,
@ChequeDate datetime, @Others Int, @ExpenseAccount Int, @DocPrefix nvarchar(50),
@BankCode nvarchar(10), @BranchCode nvarchar(10), @Denomination nvarchar(250),
@DocRef nvarchar(255), @DocSerialType nVarchar(100),@Narration nVarchar(2000),
@DocumentID Int)
as

--Get the DocumentID from Previous Collection
Declare @DocID nVarchar(50)
Declare @DocumentType Int
Declare @DocumentDetailID Int
Declare @AdjustedAmount Float
Declare @Adjustment Float

--Update Previous Collection First
Update Collections Set Balance = 0,
Status = (IsNull(Status,0) | 128) Where DocumentID = @DocumentID
--Update Collection Details
Declare UpdateCollectionDetail Cursor Static For
Select IsNull(DocumentID,0),IsNull(DocumentType,0),IsNull(AdjustedAmount,0),ABS(IsNull(Adjustment,0)) from CollectionDetail Where CollectionID = @DocumentID
Open UpdateCollectionDetail
Fetch From UpdateCollectionDetail Into @DocumentDetailID,@DocumentType,@AdjustedAmount,@Adjustment
While @@Fetch_Status = 0
Begin
if  @DocumentType = 4
Begin
Update ARVAbstract set Balance = Balance + @AdjustedAmount + @Adjustment
Where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 2
Begin
Update CreditNote set Balance = Balance + @AdjustedAmount + @Adjustment
Where CreditID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 3
Begin
Update Collections set Balance = Balance + @AdjustedAmount + @Adjustment
Where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 5
Begin
Update DebitNote set Balance = Balance + @AdjustedAmount + @Adjustment
Where DebitID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if  @DocumentType = 6
Begin
update APVAbstract set Balance = Balance + @AdjustedAmount + @Adjustment
where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 7
Begin
update Payments set Balance = Balance + @AdjustedAmount + @Adjustment
where DocumentID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End
Else if @DocumentType = 8 or @DocumentType = 9
Begin
Update ManualJournal Set Balance = Balance + @AdjustedAmount + @Adjustment
Where NewRefID = @DocumentDetailID And (Balance + @AdjustedAmount + @Adjustment) >= 0
End
IF  @DocumentType = 153
Begin
Update ServiceAbstract Set Balance = Balance + @AdjustedAmount + @Adjustment
Where InvoiceID = @DocumentDetailID and Balance + @AdjustedAmount + @Adjustment >= 0
End

Fetch Next From UpdateCollectionDetail Into @DocumentDetailID,@DocumentType,@AdjustedAmount,@Adjustment
End
Close UpdateCollectionDetail
DeAllocate UpdateCollectionDetail
--Insert New Row in the Collection Table
Select @DocID = IsNull(FullDocID,N'') from Collections Where DocumentID = @DocumentID
If @DocID = N''
Begin
Begin Tran
update DocumentNumbers set DocumentID=DocumentID+1 where DocType=57
Select @DocID=DocumentID-1 from DocumentNumbers where DocType=57
Commit Tran
SET @DocID = @DocPrefix + @DocID
End

Insert into Collections(FullDocID, DocumentDate, Value, Balance, PaymentMode,
ChequeNumber, ChequeDate, Others, ExpenseAccount, Denomination,
DocReference, BankCode, BranchCode,OriginalRef,RefDocID,DocSerialType,Narration)
values(@DocID, @DocumentDate, @Value, @Balance, @PaymentMode, @ChequeNumber,
@ChequeDate, @Others, @ExpenseAccount, @Denomination, @DocRef, @BankCode,
@BranchCode,@DocID,@DocumentID,@DocSerialType,@Narration)
Select @@IDENTITY, @DocID
