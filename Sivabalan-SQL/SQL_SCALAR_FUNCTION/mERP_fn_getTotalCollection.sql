Create Function dbo.mERP_fn_getTotalCollection(@DocID Int, @DocType Int)
Returns Decimal(18,6)
As
Begin
	Declare @AdjAmt Decimal(18, 6)

	Select @AdjAmt = Sum(AdjustedAmount) From CollectionDetail CD, Collections C 
	Where CD.DocumentID = @DocID And CD.DocumentType = @DocType And CD.CollectionID = C.DocumentID
	And IsNull(C.Status, 0) & 192 = 0
	
	Return @AdjAmt
End
