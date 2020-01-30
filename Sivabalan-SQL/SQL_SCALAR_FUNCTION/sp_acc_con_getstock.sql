CREATE Function sp_acc_con_getstock(@AccountID Int,@FromDate DateTime,@CurrentDate DateTime)
Returns Decimal(18,2)
as
Begin
Declare @AccountBalance decimal(18,2)
Declare @OPENINGSTOCK INT,@CLOSINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int
Declare @ToDate DateTime
SET @OPENINGSTOCK=22
Set @CLOSINGSTOCK=23
Set @TAXONCLOSINGSTOCK=88
Set @TAXONOPENINGSTOCK=89
Set @ToDate = @FromDate

If @AccountID=@OPENINGSTOCK
	Begin
		Select @AccountBalance=sum(opening_Value) from OpeningDetails where Opening_Date=@FromDate
		set @AccountBalance =isnull(@AccountBalance,0)
	End
	Else If @AccountID=@TAXONOPENINGSTOCK
	Begin
		Select @AccountBalance =Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then 
		(IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails where Opening_Date=@FromDate
		set @AccountBalance =isnull(@AccountBalance,0)
	End
	Else If @AccountID = @CLOSINGSTOCK
	Begin
		If @Todate<dbo.stripdatefromtime(@CurrentDate)
		Begin
			Select @AccountBalance=sum(opening_Value)from OpeningDetails 
			where Opening_Date=dateadd(day,1,@ToDate)
		End
		Else
		Begin
			--Select @AccountBalance= sum(Quantity*PurchasePrice)from Batch_Products
			Select @AccountBalance= isnull(dbo.sp_acc_getClosingStock(),0)
		End
		set @AccountBalance =isnull(@AccountBalance,0)
	End
	Else If @AccountID = @TAXONCLOSINGSTOCK
	Begin
		If @Todate<dbo.stripdatefromtime(@CurrentDate)
		Begin
			Select @AccountBalance=Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then 
			(IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails 
			where Opening_Date=dateadd(day,1,@ToDate)
		End
		Else
		Begin
			Select @AccountBalance= isnull(dbo.sp_acc_getTaxonClosingStock(),0)
		End
		set @AccountBalance =isnull(@AccountBalance,0)
	End
Return IsNull(@AccountBalance,0)
End

