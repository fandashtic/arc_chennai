Create Procedure sp_CanCancelInvoice (@InvoiceID Int, @InvValue Decimal(18,6), @PayMode Int)
As
Declare @PaymentDetails nvarchar(250)
Declare @Flag Int
Declare @Balance Decimal(18,6)
Declare @Adjusted Decimal(18,6)

Declare @Delimeter as Char(1)          
Set @Delimeter = ','          
Create Table #tmpPaymentDetails(CollectionID nvarchar(255))          
  
If @PayMode = 1
	Begin
		Select @PaymentDetails = Paymentdetails From InvoiceAbstract 
			Where InvoiceID = @InvoiceID
		If IsNull(@PaymentDetails,N'') = N''
			Begin
				Set @Flag = 0
				Goto Finish
			End
		Insert into #tmpPaymentDetails Select * From dbo.sp_SplitIn2Rows(@PaymentDetails,@Delimeter)
		Select @Balance = Sum(Balance) From Collections where DocumentID In (Select * From #tmpPaymentDetails)
		Select @Adjusted = Sum(AdjustedAmount + Adjustment) From CollectionDetail 
			Where CollectionID In (Select * From #tmpPaymentDetails) 
			And CollectionDetail.DocumentType=6
		If @Adjusted - @InvValue <> @Balance
			Set @Flag = 0
	    Else
	        Set @Flag = 1
	End
Else
	Begin
		Select @Balance = Balance from InvoiceAbstract where InvoiceID = @InvoiceID
		If @InvValue <> @Balance
			Set @Flag = 0
	    Else
	        Set @Flag = 1
	End

Finish:
	If @Flag = 0
		Select 0
	Else
		Select 1

Drop Table #tmpPaymentDetails

