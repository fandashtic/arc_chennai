CREATE Function sp_acc_con_getaccountclosingbalance(@accountid integer,@CurrentDate datetime)
Returns Decimal(18,2)
As
Begin
DECLARE @openingvalue decimal(18,2)
DECLARE @balance decimal(18,2)
Declare @DepPercent Decimal(18,2)
Declare @APVBalanceAmt Decimal(18,2)
Declare @AccountBalance Decimal(18,2)
Declare @TotDepAmt Decimal(18,2),@Exists Int,@DepAmount Decimal(18,2)
Declare @StrDate DateTime,@CheckDate DateTime,@DepAPVBalanceAmt Decimal(18,2)
Declare @TotalDepAmt Int
Declare @FIXEDASSETGROUP Int
Declare @CurrentDatePair DateTime

Set @StrDate= dbo.sp_acc_getfiscalyearstart()
Set @CheckDate =Cast(@StrDate As DateTime)
set @CheckDate = DateAdd(m, 6, @CheckDate)
set @CheckDate = DateAdd(d, 0-1, @CheckDate)
Set @CurrentDate = dbo.StripDateFromTime(@CurrentDate)
Set @CurrentDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @CurrentDate))

Set @Exists = dbo.sp_acc_con_fixedAssetrecursivefn(@AccountID)
If @Exists=1
Begin
	Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(Batch_Assets.BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and dbo.stripdatefromtime(APVAbstract.APVDate) <= @CurrentDate and IsNull(Saleable,0)=1 and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and dbo.stripdatefromtime(ARVAbstract.ARVDate) > @CurrentDate and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and
	Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID
	And ((Select dbo.stripdatefromtime(APVDate) from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @CurrentDate And dbo.stripdatefromtime(ARVAbstract.ARVDate) > @CurrentDate)
	--set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	--Set @AccountBalance = IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)
	--Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)
	Set @AccountBalance = IsNull(@AccountBalance,0)
	Set @openingvalue = @AccountBalance
	--Set @TotalDepAmt = IsNull(@TotDepAmt,0)
End
Else 
Begin
	if not exists (select top 1 OpeningValue from accountopeningbalance where [AccountID]=@accountid and OpeningDate = @CurrentDate) 
	begin
		Select @openingvalue = isNull(OpeningBalance,0) from AccountsMaster
		where AccountID=@accountID and isnull([Active],0)=1	
	end
	else
	begin
		select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance
		where [AccountID]=@accountid and OpeningDate = @CurrentDate
	end
		
	select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster
	where [TransactionDate] Between @CurrentDate And @CurrentDatePair And [GeneralJournal].AccountID = @accountid and
	documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) 
	and isnull(status,0) <> 128 and isnull(status,0) <> 192
	and [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]
End
return  (isnull(@openingvalue,0) + isnull(@balance,0))
End

