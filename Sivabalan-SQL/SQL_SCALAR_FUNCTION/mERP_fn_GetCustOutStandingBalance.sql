Create Function mERP_fn_GetCustOutStandingBalance(@Customer nvarchar(15), @InvoiceID Int)
Returns Decimal(18,6)
As
Begin
	Declare @Balance As Decimal(18,6)
	Declare @CLBalance As Decimal(18,6)
	Declare @CRBalance As Decimal(18,6)
	Declare @DBBalance As Decimal(18,6)
	Declare @INVBalance As Decimal(18,6)
	Declare @SRBalance As Decimal(18,6)

	Select @CLBalance = Sum(Balance) From Collections 
	Where CustomerID = @Customer And Balance > 0

	Select @CRBalance = Sum(Balance) From CreditNote
	Where CustomerID = @Customer And Balance > 0

	Select @DBBalance = Sum(Balance) From DebitNote
	Where CustomerID = @Customer And Balance > 0

	Select @INVBalance = Sum(Balance) From InvoiceAbstract
	Where CustomerID = @Customer And Balance > 0 And InvoiceType In (1, 3) 
	And InvoiceID <> @InvoiceID
	And Status & 128 = 0

	Select @SRBalance = Sum(Balance) From InvoiceAbstract
	Where CustomerID = @Customer And Balance > 0 And Status & 128 = 0 And
	InvoiceType = 4 And InvoiceID <> @InvoiceID

	Set @Balance = IsNull(@CLBalance, 0) + IsNull(@CRBalance, 0) + IsNull(@SRBalance, 0) - 
			IsNull(@DBBalance, 0) - IsNull(@INVBalance, 0)
	 
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') and 
	OBJECTPROPERTY(id, N'IsTable') = 1)
	Begin
		Declare @SERBalance As Decimal(18,6)
		Select @SERBalance = Sum(Balance) From ServiceInvoiceAbstract
		Where CustomerID = @Customer And Balance > 0 And IsNull(Status, 0) & 128 = 0
		Set @Balance =  @Balance - IsNull(@SERBalance, 0)	
	End
Return @Balance
End
