Create Function mERP_fn_get_RepresentChqAmt(@CollectionID Int)
Returns Decimal(18,6)
AS
Begin
	Declare @Amount Decimal(18,6)
	Select @Amount = IsNull(RepresentAmt, 0) From ChequeCollDetails Where CollectionID = @CollectionID And IsNull(ChqStatus, 0) >= 3
	Return IsNull(@Amount, 0)
End
