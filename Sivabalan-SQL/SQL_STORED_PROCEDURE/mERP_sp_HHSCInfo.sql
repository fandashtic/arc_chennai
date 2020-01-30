CREATE procedure mERP_sp_HHSCInfo (@SCNumber Integer)
As
Declare @OrdNum nVarChar(100)
Declare @PayMode Int
Declare @DiscPer Decimal(18,6)
Declare @DiscAmt Decimal(18,6)
Declare @InvSchID Int
Declare @SplSchID Int
Declare @SplSchIDs nVarChar(100)

Set @SplSchIDs = ''

Select @OrdNum = Max(OrderNumber) From Order_Details Where SaleOrderID = @SCNumber

Select @InvSchID = Max(SchemeID) from Scheme_Details 
Where OrderNumber = @OrdNum
And IsNull(OrderedProductCode,'') = ''
And SchemeID in (Select SchemeID from Schemes Where SchemeType in (1,2,3,4,97,98,99,100))

Declare SplSchs Cursor For 
Select Distinct SchemeID From Scheme_Details 
Where OrderNumber = @OrdNum
And IsNull(OrderedProductCode,'') = ''
And SchemeID Not in (Select SchemeID from Schemes Where SchemeType in (1,2,3,4))

Open SplSchs

Fetch From SplSchs InTo @SplSchID

While @@Fetch_Status = 0
Begin
	If @SplSchIDs = ''
		Set @SplSchIDs = Cast(@SplSchID As nVarChar)
	Else
		Set @SplSchIDs = @SplSchIDs + ',' + Cast(@SplSchID As nVarChar)

	Fetch Next From SplSchs InTo @SplSchID
End

Close SplSchs
DeAllocate SplSchs

Select TOP 1 @PayMode = PaymentType , @DiscPer = DiscountPer, @DiscAmt = DiscountAmt 
From Order_Header Where OrderNumber = @OrdNum

Select "PayMode" = @PayMode , "DiscPer" = @DiscPer, "DiscAmt" = @DiscAmt, "InvSchID" = @InvSchID, "SplSchIDs" = @SplSchIDs

