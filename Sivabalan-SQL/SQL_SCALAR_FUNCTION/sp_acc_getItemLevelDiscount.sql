CREATE Function sp_acc_getItemLevelDiscount (@BILLID INT,@ItemSerial INT,@DiscountOption INT)
Returns Decimal(18,6)
As
Begin
	Declare @BillDiscountAmt Decimal(18,6)
	Declare @BillDetailAmt Decimal(18,6)
	Declare @ReturnValue Decimal(18,6)
	
	Select @BillDiscountAmt = IsNULL(SUM(DiscountAmount),0) from BillDiscount Where BillID = @BILLID And ItemSerial = @ItemSerial
	Select @BillDetailAmt = IsNULL(SUM(Quantity * PurchasePrice),0) from BillDetail Where BillID = @BillID And Serial = @ItemSerial
 
 If @DiscountOption = 1 /*Percentage Discount*/
  Begin
  	If IsNULL(@BillDiscountAmt,0) <> 0 And IsNULL(@BillDetailAmt,0) <> 0
  	 Begin
  	  Set @ReturnValue = (@BillDiscountAmt / @BillDetailAmt) * 100
  	 End
  End
 Else /*Always treat it as Amount Discount*/
  Begin
   Set @ReturnValue = IsNULL(@BillDiscountAmt,0)
  End
	Return IsNULL(@ReturnValue,0)
End

