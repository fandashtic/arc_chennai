CREATE Function sp_acc_consolidatedepreciation(@AccountID Int,@ToDate Datetime)
Returns Decimal(18,2)
as 
Begin
Declare @DepPercent Decimal(18,2)
Declare @APVBalanceAmt Decimal(18,2)
Declare @AccountBalance Decimal(18,2)
Declare @TotDepAmt Decimal(18,2),@Exists Int,@DepAmount Decimal(18,2)
Declare @StrDate DateTime,@CheckDate DateTime,@DepAPVBalanceAmt Decimal(18,2)

Set @StrDate= dbo.sp_acc_getfiscalyearstart()
Set @CheckDate =Cast(@StrDate As DateTime)
set @CheckDate = DateAdd(m, 6, @CheckDate)
set @CheckDate = DateAdd(d, 0-1, @CheckDate)

Set @Exists = dbo.sp_acc_rpt_fixedAssetrecursivefn(@AccountID)

-- Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output
If @Exists=1
Begin
	Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(Batch_Assets.BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and dbo.stripdatefromtime(APVAbstract.APVDate) <= @ToDate and IsNull(Saleable,0)=1 and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate and AccountID=@AccountID

	set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	
	Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
	from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and
	Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID
	And ((Select dbo.stripdatefromtime(APVDate) from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDate And dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate)
	
	set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
	Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
	
	Set @AccountBalance = IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)
	Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)
End
Return IsNull(@TotDepAmt,0)
End

