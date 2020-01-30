CREATE procedure sp_acc_insert_FAcollectiondetail( @CollectionID integer,
@DocumentID integer,
@DocumentType integer,
@DocumentDate datetime,
@PaymentDate datetime,
@AdjustedAmount float,
@OriginalID nVarchar(128),
@DocumentValue float,
@ExtraAmount float,
@FullyAdjust int = 0,
@Adjustment float = 0,
@DocRef nVarchar(125) = N'',
@TempAdjustedAmount float = null)
as

insert into CollectionDetail(
CollectionID,
DocumentID,
DocumentType,
DocumentDate,
PaymentDate,
AdjustedAmount,
OriginalID,
DocumentValue,
ExtraCollection,
Adjustment,
DocRef)
values
(@CollectionID,
@DocumentID,
@DocumentType,
@DocumentDate,
@PaymentDate,
@AdjustedAmount,
@OriginalID,
@DocumentValue,
@ExtraAmount,
@Adjustment,
@DocRef)

If isnull(@TempAdjustedAmount,0) > 0
Begin
set @AdjustedAmount = @TempAdjustedAmount
End
/* If Adjustment is givend add it to the Adjusted Amount */
If Isnull(@Adjustment,0) < 0
Begin
Set @AdjustedAmount = Isnull(@AdjustedAmount,0) + Abs(@Adjustment)
End

if  @DocumentType = 4
Begin
If @FullyAdjust = 1
Begin
Update ARVAbstract Set Balance = 0 Where DocumentID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update ARVAbstract set Balance = Balance - @AdjustedAmount
where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if @DocumentType = 2
Begin
If @FullyAdjust = 1
Begin
Update CreditNote Set Balance = 0 Where CreditID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update CreditNote set Balance = Balance - @AdjustedAmount
where CreditID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if @DocumentType = 3
Begin
If @FullyAdjust = 1
Begin
Update Collections Set Balance = 0 Where DocumentID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update Collections set Balance = Balance - @AdjustedAmount
where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if @DocumentType = 5
Begin
If @FullyAdjust = 1
Begin
Update DebitNote Set Balance = 0 Where DebitID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update DebitNote set Balance = Balance - @AdjustedAmount
where DebitID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if  @DocumentType = 6
Begin
If @FullyAdjust = 1
Begin
Update APVAbstract Set Balance = 0 Where DocumentID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update APVAbstract set Balance = Balance - @AdjustedAmount
where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if @DocumentType = 7
Begin
If @FullyAdjust = 1
Begin
Update Payments Set Balance = 0 Where DocumentID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
update Payments set Balance = Balance - @AdjustedAmount
where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End
else if @DocumentType = 8 or @DocumentType = 9
Begin
If @FullyAdjust = 1
Begin
Update ManualJournal Set Balance = 0
Where NewRefID = @DocumentID And
(Balance - @AdjustedAmount) >= 0
End
Else
Begin
Update ManualJournal Set Balance = Balance - @AdjustedAmount
Where NewRefID = @DocumentID And
(Balance - @AdjustedAmount) >= 0
End
End
Else IF  @DocumentType = 153
Begin
If @FullyAdjust = 1
Begin
Update ServiceAbstract Set Balance = 0 Where InvoiceID = @DocumentID And
Balance - @AdjustedAmount >= 0
End
Else
Begin
Update ServiceAbstract Set Balance = Balance - @AdjustedAmount
where InvoiceID = @DocumentID and Balance - @AdjustedAmount >= 0
End
End

Select @@RowCount

