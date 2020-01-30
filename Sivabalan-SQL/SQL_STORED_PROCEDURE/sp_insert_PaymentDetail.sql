CREATE procedure sp_insert_PaymentDetail(	@PaymentID integer,
						@DocumentID integer,
						@DocumentType integer,
						@DocumentDate datetime,
						@PaymentDate datetime,
						@AdjustedAmount Decimal(18,6), 
						@OriginalID nVarchar(128),
						@DocumentValue Decimal(18,6),
						@DocumentReference nvarchar(50),
						@ExtraCollection Decimal(18,6),
						@Fully int = 0,
						@Adjustment Decimal(18,6) = 0)

as

insert into PaymentDetail(	PaymentID,
				DocumentID,
				DocumentType,
				DocumentDate,
				PaymentDate,
				AdjustedAmount,
				OriginalID,
				DocumentValue,
				DocumentReference,
				ExtraCol,
				Adjustment)
values
				(@PaymentID,
				@DocumentID,
				@DocumentType,
				@DocumentDate,
				@PaymentDate,
				@AdjustedAmount,
				@OriginalID,
				@DocumentValue,
				@DocumentReference,
				@ExtraCollection,
				@Adjustment)

if @DocumentType = 1 
Begin
	If @Fully = 1
	Begin
		Update AdjustmentReturnAbstract Set Balance = 0 
		Where AdjustmentID = @DocumentID And Balance - @AdjustedAmount >= 0
	End
	Else
	Begin
		update AdjustmentReturnAbstract set Balance = Balance - @AdjustedAmount 
		where AdjustmentID = @DocumentID  And Balance - @AdjustedAmount >= 0
	End
End
else if @DocumentType = 2
Begin
	If @Fully = 1 
	Begin
		Update DebitNote Set Balance = 0 Where DebitID = @DocumentID 
		And Balance - @AdjustedAmount >= 0
	End
	Else
	Begin
		update DebitNote set Balance = Balance - @AdjustedAmount
		where DebitID = @DocumentID And Balance - @AdjustedAmount >= 0
	End
End
else if @DocumentType = 3
Begin
	If @Fully = 1
	Begin
		Update Payments Set Balance = 0 Where DocumentID = @DocumentID
		And Balance - @AdjustedAmount >= 0
	End
	Else
	Begin
		update Payments set Balance = Balance - @AdjustedAmount
		where DocumentID = @DocumentID
	End
End
else if @DocumentType = 4
Begin
	If @Fully = 1
	Begin
		Update BillAbstract Set Balance = 0 Where BillID = @DocumentID
		And Balance - @AdjustedAmount >= 0
	End
	Else
	Begin
		update BillAbstract set Balance = Balance - @AdjustedAmount
		where BillID = @DocumentID
	End
End
else if @DocumentType = 5
Begin
	If @Fully = 1
	Begin
		Update CreditNote Set Balance = 0 Where CreditID = @DocumentID
		And Balance - @AdjustedAmount >= 0
	End
	Else
	Begin
		update CreditNote set Balance = Balance - @AdjustedAmount
		where CreditID = @DocumentID
	End
End
Else If @DocumentType = 6
Begin
	If @Fully = 1
	Begin
		Update ClaimsNote Set Balance = 0 Where ClaimID = @DocumentID
		And IsNull(Balance, 0) - @AdjustedAmount >=0
	End
	Else
	Begin
		Update ClaimsNote Set Balance = IsNull(Balance, 0) - @AdjustedAmount
		Where ClaimID = @DocumentID
	End
End
Select @@RowCount
