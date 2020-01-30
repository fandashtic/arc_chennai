CREATE Function fn_GetAmountCollected (@PaymentDetail nvarchar(255),
					@PaymentMode nvarchar(255))
Returns Decimal(18,6)
Begin
	Declare @Mode as int
	Declare @Amount as Decimal(18,6)
	Declare @Delimeter as Char(1)      
	Set @Delimeter=','

	If @PaymentMode = 'Cash' 
		Set @Mode = 0
	Else If @PaymentMode = 'Cheque'
		Set @Mode = 1
 	Else If @PaymentMode = 'DD' 
 		Set @Mode = 2
	Else If @PaymentMode = 'Credit Card'
		Set @Mode = 3
	Else If @PaymentMode = 'Coupon'
		Set @Mode = 5
	Else If @PaymentMode = 'Credit Note' 
		Set @Mode = 6
	Else If @PaymentMode = 'Gift Voucher' 
		Set @Mode = 7  

	Declare @CollectionTemp Table (CID Decimal(18,6), PaymentMode nvarchar(100),
		Amount Decimal(18,6))
	Insert @CollectionTemp select ItemValue, @PaymentMode, 0 from dbo.sp_SplitIn2Rows(@PaymentDetail,@Delimeter)      
	
	Update @CollectionTemp Set Amount = Value from Collections CAbstract Where 
		CAbstract.DocumentID = CID And CAbstract.PaymentMode = @Mode And 
		CAbstract.Value <> 0

	Select @Amount = Sum(Amount) from @CollectionTemp
	Return @Amount
End



