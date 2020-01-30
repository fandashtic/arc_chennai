CREATE Function GetAdjustmentValue(@InvoiceID Int, @AdjReasonID Int)
Returns Decimal(18, 6)
Begin

Declare @AdjValue Decimal(18, 6)

Select @AdjValue = Sum(Case DocumentType When 2 Then 0 - Amount Else Amount End) 
From AdjustmentReference Where InvoiceID = @InvoiceID And
AdjustmentReasonID = @AdjReasonID And TransactionType = 0

Return @AdjValue 

End

