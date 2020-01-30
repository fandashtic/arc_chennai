CREATE Procedure sp_acc_con_rpt_TradingACVertical(@FromDate DateTime, @Todate DateTime)
As
Declare @NEXTLEVEL INT,@LASTLEVEL INT,@LEAFACCOUNT INT,@ACCOUNTGROUP INT
Declare @PROFITANDLOSS INT
Declare @SALESACCOUNT INT
Declare @SPECIALCASE2 int
Declare @SPECIALCASE4 int
Declare @Balance Decimal(18,2),@GroupCode Int,@group nvarchar(25),@AccountType Int
Declare @OrganisationType Int

DECLARE @OPENINGSTOCKGROUP INT,@CLOSINGSTOCKGROUP Int
SET @OPENINGSTOCKGROUP=54
Set @CLOSINGSTOCKGROUP=55

Declare @GrossValue Decimal(18,2),@NetExpAmount Decimal(18,2),@NetIncAmount Decimal(18,2)
Declare @NetIID Decimal(18,2),@NetEID Decimal(18,2),@netValue Decimal(18,2)

SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2
SET @ACCOUNTGROUP =3
SET @SPECIALCASE2 =5
SET @SPECIALCASE4=100

SET @PROFITANDLOSS=12
SET @SALESACCOUNT=28

	Create table #TempTrading(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTrading1(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingED(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingID(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	--Create table #TempTradingInDirect(AccountName varchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingIID(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingEID(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)

	Create table #TempTradingIID1(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingEID1(AccountName nvarchar(25),Amount Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)

	
	Insert #TempTrading
	Select 'Trading Account' ,Null, Null,Null, Null, Null,Null,@LASTLEVEL

	Set @Balance=0
	execute sp_acc_con_rpt_tradingacrecursivebalancestock @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
	Insert #TempTradingED
	Select 'Opening Stock',IsNull(@Balance,0),@OPENINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Opening Stock GroupID
	
	DECLARE scanrootlevel CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType from ConsolidateAccountGroup where ParentGroup=0 and 
	AccountType in (4,5,6,7) order by AccountType desc,GroupID Desc
	
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			Set @Balance=0
			execute sp_acc_con_rpt_tradingacrecursivebalance @GroupCode,@FromDate,@ToDate,@Balance output
		
			If @AccountType=6
			Begin
				Insert #TempTradingED
				Select @Group,isnull(@Balance,0),@GroupCode,@FromDate,@ToDate,0,0,@ACCOUNTGROUP 
			end
			Else If @AccountType=4
			Begin
				If @GroupCode=@SALESACCOUNT
				Begin
					Insert #TempTradingID
					Select @Group,case when isnull(@Balance,0)<0 then abs(isnull(@Balance,0)) else (0-isnull(@Balance,0)) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
				End
			End
			Else If @AccountType=5
			Begin
				Insert #TempTradingIID
				Select  @Group,case when isnull(@Balance,0)<0 then abs(isnull(@Balance,0)) else (0-isnull(@Balance,0)) end,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
			end
			Else If @AccountType=7
			Begin
				Insert #TempTradingEID
				Select @Group,isnull(@Balance,0),@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
			end
		End	
	
		FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
	Set @Balance=0
	execute sp_acc_con_rpt_tradingacrecursivebalancestock @CLOSINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
	Insert #TempTradingID
	Select 'Closing Stock',IsNull(@Balance,0),@CLOSINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Closing Stock GroupID

	DECLARE scanrootlevel CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType from ConsolidateAccountGroup where ParentGroup=0 and 
	AccountType in (4) and GroupID <> @SALESACCOUNT order by AccountType desc,GroupID Desc
	
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			Set @Balance=0
			execute sp_acc_con_rpt_tradingacrecursivebalance @GroupCode,@FromDate,@ToDate,@Balance output
		
-- 			If @AccountType=6
-- 			Begin
-- 				Insert #TempTradingED
-- 				Select @Group,isnull(@Balance,0),@GroupCode,@FromDate,@ToDate,0,0,@ACCOUNTGROUP 
-- 			end
-- 			Else If @AccountType=4
-- 			Begin
-- 				If @GroupCode=@SALESACCOUNT
-- 				Begin
					Insert #TempTradingID
					Select @Group,case when isnull(@Balance,0)<0 then abs(isnull(@Balance,0)) else (0-isnull(@Balance,0)) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
-- 				End
-- 			End
-- 			Else If @AccountType=5
-- 			Begin
-- 				Insert #TempTradingIID
-- 				Select  @Group,case when isnull(@Balance,0)<0 then abs(isnull(@Balance,0)) else (0-isnull(@Balance,0)) end,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
-- 			end
-- 			Else If @AccountType=7
-- 			Begin
-- 				Insert #TempTradingEID
-- 				Select @Group,isnull(@Balance,0),@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
-- 			end
		End	
	
		FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
	Select @NetExpAmount=Sum(isnull(Amount,0)) from #TempTradingED
	Select @NetIncAmount=Sum(isnull(Amount,0)) from #TempTradingID
	Set @GrossValue=isnull(@NetExpAmount,0)-isnull(@NetIncAmount,0)

	If isnull(@GrossValue,0) > 0
	Begin
		Insert #TempTradingID
		Select 'Gross Loss',@GrossValue,Null,Null,Null,0,0,@LASTLEVEL
		
	End
	Else If isnull(@GrossValue,0) <= 0 
	Begin
		Insert #TempTradingED
		Select 'Gross Profit',Abs(@GrossValue),Null,Null,Null,0,0,@LASTLEVEL
	End

	Insert #TempTrading
	Select  * from #TempTradingID
	Insert #TempTrading
	Select 'Total' ,Sum(isnull(Amount,0)),Null, Null,Null,NUll,NUll,@LASTLEVEL from #TempTradingID
	Insert #TempTrading
	Select  * from #TempTradingED
	Insert #TempTrading
	Select 'Total' ,Sum(isnull(Amount,0)),Null, Null,Null,NUll,NUll,@LASTLEVEL from #TempTradingED
	
	
	Insert #TempTrading
	Select Null, Null, Null, Null, Null, NUll, NUll, @LASTLEVEL
	
	
	Insert #TempTrading1
	Select 'P & L Account' ,Null, Null, Null,Null,Null,NUll,@LASTLEVEL
	
	Select @OrganisationType=OrganisationType from Setup
	If @OrganisationType=2--Partnership
	Begin
		If isnull(@GrossValue,0) > 0
		Begin
			Insert #TempTradingEID1
			Select 'Gross Loss',@GrossValue,Null,Null,Null,0,0,@LASTLEVEL
			Insert #TempTradingEID1
			Select * from #TempTradingEID
			Insert #TempTradingIID1
			Select * from #TempTradingIID
			Select @NetEID = isnull(sum(Amount),0) from #TempTradingEID1
			Select @NetIID = isnull(sum(Amount),0) from #TempTradingIID1
			Set @NetValue=@NetEID-@NeTIID
			If @NetValue >0 
			Begin
				Insert #TempTradingIID1
				Select 'Net Loss',@NetValue,0,@FromDate,@ToDate,0,0,@SPECIALCASE4
			End
			Else If @NetValue <=0 
			Begin
				Insert #TempTradingEID1
				Select 'Net Profit',abs(@NetValue),0,@FromDate,@ToDate,0,0,@SPECIALCASE4
			End
	
	
		End
		Else If isnull(@GrossValue,0) <= 0
		Begin			Insert #TempTradingIID1
			Select 'Gross Profit',abs(@GrossValue),Null,Null,Null,0,0,@LASTLEVEL
			Insert #TempTradingIID1
			Select * from #TempTradingIID
			Insert #TempTradingEID1
			Select * from #TempTradingEID
			Select @NetIID = isnull(sum(Amount),0) from #TempTradingIID1
			Select @NetEID = isnull(sum(Amount),0) from #TempTradingEID1
			Set @NetValue=@NetEID-@NeTIID
			If @NetValue >0 
			Begin
				Insert #TempTradingIID1
				Select 'Net Loss',@NetValue,0,@FromDate,@ToDate,0,0,@SPECIALCASE4
			End
			Else If @NetValue <=0 
			Begin
				Insert #TempTradingEID1
				Select 'Net Profit',abs(@NetValue),0,@FromDate,@ToDate,0,0,@SPECIALCASE4
			End
	
		End
	
	End
	Else
	Begin
		If isnull(@GrossValue,0) > 0
		Begin
			Insert #TempTradingEID1
			Select 'Gross Loss',@GrossValue,Null,Null,Null,0,0,@LASTLEVEL
			Insert #TempTradingEID1
			Select * from #TempTradingEID
			Insert #TempTradingIID1
			Select * from #TempTradingIID
			Select @NetEID = isnull(sum(Amount),0) from #TempTradingEID1
			Select @NetIID = isnull(sum(Amount),0) from #TempTradingIID1
			Set @NetValue=@NetEID-@NeTIID
			If @NetValue >0 
			Begin
				Insert #TempTradingIID1
				Select 'Net Loss',@NetValue,Null,Null,Null,0,0,@LASTLEVEL
			End
			Else If @NetValue <=0 
			Begin
				Insert #TempTradingEID1
				Select 'Net Profit',abs(@NetValue),Null,Null,Null,0,0,@LASTLEVEL
			End
	
	
		End
		Else If isnull(@GrossValue,0) <= 0
		Begin
			Insert #TempTradingIID1
			Select 'Gross Profit',abs(@GrossValue),Null,Null,Null,0,0,@LASTLEVEL
			Insert #TempTradingIID1
			Select * from #TempTradingIID
			Insert #TempTradingEID1
			Select * from #TempTradingEID
			Select @NetIID = isnull(sum(Amount),0) from #TempTradingIID1
			Select @NetEID = isnull(sum(Amount),0) from #TempTradingEID1
			Set @NetValue=@NetEID-@NeTIID
			If @NetValue >0 
			Begin
				Insert #TempTradingIID1
				Select 'Net Loss',@NetValue,Null,Null,Null,0,0,@LASTLEVEL
			End
			Else If @NetValue <=0 
			Begin
				Insert #TempTradingEID1
				Select 'Net Profit',abs(@NetValue),Null,Null,Null,0,0,@LASTLEVEL
			End
	
		End
	End
	Insert #TempTradingEID1
	Select 'Total' ,Sum(isnull(Amount,0)),Null, Null,Null,NUll,NUll,@LASTLEVEL from #TempTradingEID1
	Insert #TempTradingIID1
	Select 'Total' ,Sum(isnull(Amount,0)),Null, Null,Null,NUll,NUll,@LASTLEVEL from #TempTradingIID1

	Insert #TempTrading1
	Select * from #TempTradingIID1
	Insert #TempTrading1
	Select * from #TempTradingEID1
	
	Insert #TempTrading
	Select * from #TempTrading1
	
	Select "Group Name" = AccountName ,Amount ,0,AccountID,FromDate ,ToDate ,DocRef ,DocType ,HighLight,Case when AccountName='Net Profit' then Amount else (Case When AccountName='Net Loss' Then (0-Amount) Else Null End) End, HighLight  from #TempTrading
	Drop Table #TempTrading1
	Drop table #TempTrading
	Drop Table #TempTradingED
	Drop Table #TempTradingID
	Drop Table #TempTradingEID
	Drop Table #TempTradingIID
	Drop Table #TempTradingEID1
	Drop Table #TempTradingIID1

