Create Function sp_acc_con_consolidatedepreciation(@AccountID Int,@ToDate Datetime,@Mode Int)
Returns Decimal(18,6)
as 
Begin
Declare @GroupID Int
Declare @DepPercent Decimal(18,6)
Declare @APVBalanceAmt Decimal(18,6)
Declare @AccountBalance Decimal(18,6)
Declare @TotDepAmt Decimal(18,6),@Exists Int,@DepAmount Decimal(18,6)
Declare @StrDate DateTime,@CheckDate DateTime,@DepAPVBalanceAmt Decimal(18,6)
Declare @TotalDepAmt Int
Declare @FIXEDASSETGROUP Int
Declare @DepAccountID Int
Declare @count int

Set @count =0
Set @FIXEDASSETGROUP=13

If @Mode = 1 
Begin
	Set @StrDate= dbo.sp_acc_getfiscalyearstart()
	Set @CheckDate =Cast(@StrDate As DateTime)
	set @CheckDate = DateAdd(m, 6, @CheckDate)
	set @CheckDate = DateAdd(d, 0-1, @CheckDate)
	
	Set @Exists = dbo.sp_acc_con_fixedAssetrecursivefn(@AccountID)
	-- Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output
	If @Exists=1
	Begin
		Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)
		
		Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
		from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID
	
		Set @DepAmount=IsNull(@DepAPVBalanceAmt,0)
		Set @AccountBalance=IsNull(@APVBalanceAmt,0)
		
		Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(Batch_Assets.BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
		from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and dbo.stripdatefromtime(APVAbstract.APVDate) <= @ToDate and IsNull(Saleable,0)=1 and AccountID=@AccountID
	
		Set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
		Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
		
		Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
		from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate and AccountID=@AccountID
	
		Set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
		Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
		
		Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
		from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and
		Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID
		And ((Select dbo.stripdatefromtime(APVDate) from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDate And dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate)
		
		Set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
		Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)
		
		Set @AccountBalance = IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)
		Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)
		
		Set @TotalDepAmt = IsNull(@TotDepAmt,0)
	End
End
Else If @Mode = 2
Begin
	Declare @TempDepComp Table(GroupID int)
	Insert into @TempDepComp
	select GroupID From AccountGroup Where ParentGroup = @FixedAssetGroup --and isnull(Active,0)=1

	Declare Parent Cursor Dynamic For
	Select GroupID From @TempDepComp
	Open Parent
	Fetch From Parent Into @GroupID
	While @@Fetch_Status = 0
	Begin
		Insert into @TempDepComp 
		Select GroupID From AccountGroup Where ParentGroup = @GroupID --and isnull(Active,0)=1
		Fetch Next From Parent Into @GroupID
	End
	Close Parent
	DeAllocate Parent
	
	insert into @TempDepComp values(@FixedAssetGroup)
	
	Declare @OpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)

	Set @StrDate=  dbo.sp_acc_GetFiscalYearStart()
	Set @CheckDate =Cast(@StrDate As DateTime)
	set @CheckDate = DateAdd(m, 6, @CheckDate)
	set @CheckDate = DateAdd(d, 0-1, @CheckDate)
	
	Declare TotalAccount Cursor Keyset For
	Select AccountID From AccountsMaster where GroupID in (Select * from @TempDepComp) --and isnull(Active,0)=1
	Open TotalAccount
	Fetch From TotalAccount Into @DepAccountID
	While @@Fetch_Status = 0
	Begin
		Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@DepAccountID),0)
		If @DepPercent>0 
		Begin
			Set @DepAmount=0
			Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(Batch_Assets.BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) 
			from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@DepAccountID 
			set @DepAmount=IsNull(@DepAPVBalanceAmt,0)
	
			Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(Batch_Assets.BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) 
			from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and dbo.stripdatefromtime(APVAbstract.APVDate) <= @ToDate and IsNull(Saleable,0)=1 and AccountID=@DepAccountID 
			set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)
	
			Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) 
			from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate and AccountID=@DepAccountID
			set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)
	
			Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) 
			from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and
			Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@DepAccountID
			And ((Select dbo.stripdatefromtime(APVDate) from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDate And dbo.stripdatefromtime(ARVAbstract.ARVDate) > @ToDate)

			set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)
			Set @TotalDepAmt=IsNull(@TotalDepAmt,0) + IsNull(@DepAmount,0)

		End
		Fetch Next From TotalAccount Into @DepAccountID
	End
	CLOSE TotalAccount
	DEALLOCATE TotalAccount 
	Set @TotalDepAmt =isnull(@TotalDepAmt,0)
End
Return IsNull(@TotalDepAmt,0)
End


