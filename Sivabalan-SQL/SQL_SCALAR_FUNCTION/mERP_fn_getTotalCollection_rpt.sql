create Function dbo.mERP_fn_getTotalCollection_rpt(@DocID Int, @DocType Int, @CollID int) 
Returns Decimal(18,6) 
As 
Begin 
	Declare @AdjAmt Decimal(18, 6)  
	Select @AdjAmt = 
    --Sum(AdjustedAmount) 
        case Max(CD.DocumentType) 
		when 1 then 0 - Sum(AdjustedAmount) --'Sales Return'
		when 2 then 0 - Sum(AdjustedAmount)  -- 'Credit Note'
		when 3 then 0 - Sum(AdjustedAmount)  --'Advance Collection'
		when 4 then Sum(AdjustedAmount)  --'Invoice'
		when 5 then Sum(AdjustedAmount)  -- Debit Note
		end
    From CollectionDetail CD, Collections C Where 
	CD.DocumentID = @DocID And 
	C.documentid = @CollID And
	CD.DocumentType = @DocType And 
	CD.CollectionID = C.DocumentID And 
	IsNull(C.Status, 0) & 192 = 0  
	Return @AdjAmt 
End 
