CREATE Function ReturnSetting(@PaymentType Int)
Returns Int
As
Begin
Declare @Type Int
Declare @CASH Int
Declare @CHEQUE Int 
Declare @CREDITCARD Int
Declare @COUPON Int
Declare @OTHERS Int

Set @CASH = 1
Set @CHEQUE = 2
Set @CREDITCARD = 3
Set @COUPON = 4
Set @OTHERS = 5

If @PaymentType = @CASH
Begin
	Set @Type = 5
End
Else If @PaymentType = @CHEQUE
Begin
	Set @Type = 45
End
Else If @PaymentType = @CREDITCARD
Begin
	Set @Type = 46
End
Else If @PaymentType = @COUPON
Begin
	Set @Type = 47
End
Else If @PaymentType = @OTHERS
Begin
	Set @Type = 50
End
Return @Type
End








