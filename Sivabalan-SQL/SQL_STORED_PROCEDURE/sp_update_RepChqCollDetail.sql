CREATE Procedure sp_update_RepChqCollDetail
(
	@CollectionID integer,
	@DocumentID integer,
	@DocumentType integer,
	@Amount Decimal(18,6)
)
As
Begin
	Update ChequeCollDetails Set RepresentID = @CollectionID, RepresentAmt = @Amount,
	ChqStatus = 3 Where IsNull(DebitID, 0) = @DocumentID
End
