Create function fn_getInvCollectedAmount(@CustomerId nVarchar(100),@InvoiceId Int,@ToDate datetime)
Returns decimal(18,6)
as
Begin
declare @AdjAmt decimal(18,6)
	select @AdjAmt = sum(Isnull(AdjustedAmount,0)) from Collections Abst,CollectionDetail Det
	where 
	Det.DocumentID = @InvoiceId  
	and Abst.DocumentID = Det.CollectionId 
    and Abst.CustomerId=@CustomerID 
--	and Det.PaymentDate <= @ToDate 
	and Det.DocumentDate <= @ToDate 
	and Isnull(Abst.Status,0) & 192 = 0
	return @AdjAmt
End

