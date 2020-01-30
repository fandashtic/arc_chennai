CREATE procedure sp_ser_insertcollectiondetail(
				@CollectionID integer,
				@DocumentID integer,
				@DocumentType integer,
				@DocumentDate datetime,
				@PaymentDate datetime,
				@AdjustedAmount Decimal(18,6), 
				@OriginalID nVarchar(128),
				@DocumentValue Decimal(18,6),
				@ExtraAmount Decimal(18,6) = 0,
				@FullyAdjust int = 0,
				@Adjustment Decimal(18,6) = 0,
				@DocRef Varchar(125) = '')
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

if @DocumentType = 12 
Begin
	If @FullyAdjust = 1 	/* Balance = 0 */
		Update ServiceInvoiceAbstract Set Balance = 0 
		Where ServiceInvoiceID = @DocumentID And Balance - @AdjustedAmount >= 0
	else 
		update ServiceInvoiceAbstract set Balance = Balance - @AdjustedAmount
		where ServiceInvoiceID = @DocumentID and Balance - @AdjustedAmount >= 0
End

Select @@RowCount 

/*	
Originally copied from ERp Forum
Procedure to update Service invoice only
*/



