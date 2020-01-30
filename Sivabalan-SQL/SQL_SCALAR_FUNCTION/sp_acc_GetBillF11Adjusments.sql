Create Function sp_acc_GetBillF11Adjusments(@BillID Integer, @DocType Integer)
Returns Decimal(18,6)
As
Begin
Declare @ReturnValue Decimal(18,6)

Declare @Bill Integer
Set @Bill = 8

If @DocType = @Bill
 Begin
  Select @ReturnValue = AdjustmentValue from BillAbstract Where BillID = @BillID
 End
Return IsNull(@ReturnValue,0)
End

