CREATE procedure sp_ser_insert_collectiondetail(
				@CollectionID integer,
				@DocumentID integer,
				@DocumentType integer,
				@DocumentDate datetime,
				@PaymentDate datetime,
				@AdjustedAmount Decimal(18,6), 
				@OriginalID nVarchar(128),
				@DocumentValue Decimal(18,6),
				@DocRef Varchar(125) = '', 
				@ExtraCollection decimal(18,6) = 0, @FullyAdjust int = 0)
as
declare @updated as int
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
				@ExtraCollection,
				0,
				@DocRef)
set @updated = @@RowCount 

if @DocumentType = 12 
Begin
	/* Balance = 0 */
	update ServiceInvoiceAbstract set Balance = Balance - @AdjustedAmount, 
	PaymentDetails = @CollectionID 
	where ServiceInvoiceID = @DocumentID and Balance - @AdjustedAmount >= 0
	set @updated = @@RowCount 
End
else if @DocumentType = 2
Begin
	If @FullyAdjust = 1
	Begin
		Update CreditNote Set Balance = 0 Where CreditID = @DocumentID And
		Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 
	End
	Else
	Begin
		update CreditNote set Balance = Balance - @AdjustedAmount
		where CreditID = @DocumentID and Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 
	End
End
else if @DocumentType = 3
Begin
	If @FullyAdjust = 1
	Begin
		Update Collections Set Balance = 0 Where DocumentID = @DocumentID And
		Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 
	End
	Else
	Begin
		update Collections set Balance = Balance - @AdjustedAmount
		where DocumentID = @DocumentID and Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 
	End
End
else if @DocumentType = 5
Begin
	If @FullyAdjust = 1
	Begin
		Update DebitNote Set Balance = 0 Where DebitID = @DocumentID And
		Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 
	End
	Else
	Begin
		update DebitNote set Balance = Balance - @AdjustedAmount
		where DebitID = @DocumentID and Balance - @AdjustedAmount >= 0
		set @updated = @@RowCount 	
	End
End
Select @updated



