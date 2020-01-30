
CREATE Procedure sp_acc_con_rpt_BalanceSheetTradingAC(@FromDate DateTime, @Todate DateTime,@Company nVarchar(128),@TradingBalance Decimal(18,2) Output)
As
Set @TradingBalance=0
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
Declare @OPENINGSTOCK INT,@CLOSINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int
SET @OPENINGSTOCK=22
Set @CLOSINGSTOCK=23
Set @TAXONCLOSINGSTOCK=88
Set @TAXONOPENINGSTOCK=89
SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2
SET @ACCOUNTGROUP =3
SET @SPECIALCASE2 =5
SET @SPECIALCASE4=100 -- Details of NetProfit
SET @PROFITANDLOSS=12
SET @SALESACCOUNT=28

Declare @SPECIALFORMAT INT
Set @SPECIALFORMAT =9

Declare @Fixed Int

	Create table #TempTrading(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTrading1(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingED(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingID(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingInDirectIncome(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	Create table #TempTradingInDirectExpense(AccountName nvarchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	
	Insert #TempTrading
	Select 'Trading Account' ,Null, Null, Null,Null, Null, Null,Null,@LASTLEVEL
	Set @Balance=0
	execute sp_acc_con_rpt_Companytradingrecursivebalance @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Company,3,1,@balance output,@SPECIALFORMAT
	--execute sp_acc_con_rpt_tradingacrecursivebalancestock @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Balance output,@SPECIALFORMAT
	Insert #TempTradingED
	Select 'Opening Stock',@Balance,Null,@OPENINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Opening Stock GroupID
	
	DECLARE scanrootlevel1 CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType,Fixed from ReceiveAccountGroup where ParentGroup=0 and 
	AccountType in (4,5,6,7) and CompanyID=@Company order by AccountType desc,GroupID Desc
	
	OPEN scanrootlevel1
	
	FETCH FROM scanrootlevel1 into @GroupCode,@group,@AccountType,@Fixed
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			Set @Balance=0

			execute sp_acc_con_rpt_Companytradingrecursivebalance @GroupCode,@FromDate,@ToDate,@Company,3,@Fixed,@Balance output,@SPECIALFORMAT
		
			If @AccountType=6
			Begin
				Insert #TempTradingED
				Select @Group,@Balance,Null,@GroupCode,@FromDate,@ToDate,0,0,@ACCOUNTGROUP
			end
			Else If @AccountType=4
			Begin
				If @GroupCode=28
				Begin
					Insert #TempTradingID
					Select @Group,Null,case when IsNull(@Balance,0)<0 then abs(IsNull(@Balance,0)) else (0-IsNull(@Balance,0)) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
				End
			End
			Else If @AccountType=5
			Begin
				
				Insert #TempTradingIndirectIncome
				Select  @Group,Null,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
			end
			Else If @AccountType=7
			Begin
				
				Insert #TempTradingIndirectExpense
				Select @Group,@Balance,Null,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
			end
		End	
	
		FETCH NEXT FROM scanrootlevel1 into @GroupCode,@group,@AccountType,@Fixed
	END
	CLOSE scanrootlevel1
	DEALLOCATE scanrootlevel1
	Set @Balance=0
--	execute sp_acc_con_rpt_tradingacrecursivebalancestock @CLOSINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
	execute sp_acc_con_rpt_Companytradingrecursivebalance @CLOSINGSTOCKGROUP,@FromDate,@ToDate,@Company,3,1,@balance output
	Insert #TempTradingID
	Select 'Closing Stock',Null,@Balance,@CLOSINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Closing Stock GroupID
	DECLARE scanrootlevel1 CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType,Fixed from ConsolidateAccountGroup where ParentGroup=0 and 
	AccountType in (4) and GroupID <> @SALESACCOUNT and CompanyID=@Company order by AccountType desc,GroupID Desc
	
	OPEN scanrootlevel1
	
	FETCH FROM scanrootlevel1 into @GroupCode,@group,@AccountType,@Fixed
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			--execute sp_acc_con_rpt_tradingacrecursivebalance @GroupCode,@FromDate,@ToDate,@Balance output,@SPECIALFORMAT
			execute sp_acc_con_rpt_Companytradingrecursivebalance @GroupCode,@FromDate,@ToDate,@Company,3,@Fixed,@Balance output,@SPECIALFORMAT
		
					Insert #TempTradingID
					Select @Group,Null,case when IsNull(@Balance,0)<0 then abs(IsNull(@Balance,0)) else (0-IsNull(@Balance,0)) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
		End	
	
		FETCH NEXT FROM scanrootlevel1 into @GroupCode,@group,@AccountType,@Fixed
	END
	CLOSE scanrootlevel1
	DEALLOCATE scanrootlevel1
	
	Insert #TempTrading
	Select  * from #TempTradingID
	Insert #TempTrading
	Select  * from #TempTradingED
	Insert #TempTrading
	Select case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then 'Gross Loss' else 'Gross Profit' end,
	case when Sum(isnull(Debit,0)-isnull(Credit,0)) < 0 then abs(Sum(isnull(Debit,0)-isnull(Credit,0))) else Null end,
	case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then Sum(isnull(Debit,0)-isnull(Credit,0)) else Null end,Null,Null,Null,NUll,NUll,@LASTLEVEL from #TempTrading
	
	Insert #TempTrading
	Select 'Total' ,Sum(Debit), Sum(Credit), Null, Null,Null,NUll,NUll,@LASTLEVEL from #TempTrading
	
	Insert #TempTrading
	Select Null ,Null, Null, Null, Null,Null,NUll,NUll,@LASTLEVEL
	
	Insert #TempTrading1
	Select 'P & L Account' ,Null, Null, Null,Null,Null,NUll,NUll,@LASTLEVEL
	
	Insert #TempTrading1
	Select AccountName, case when Debit is Null then Credit else Null end,case when Debit is not Null then Debit else Null end,Null,Null,Null,NUll,NUll,@LASTLEVEL from #TempTrading where AccountName='Gross Loss' or AccountName='Gross Profit'
	
	Insert #TempTrading1
	Select  * from #TempTradingIndirectIncome
	Insert #TempTrading1
	Select  * from #TempTradingIndirectExpense



	Select @TradingBalance=Sum(isnull(Debit,0)-isnull(Credit,0)) from #TempTrading1
	Set @TradingBalance=IsNull(@TradingBalance,0)

	Drop Table #TempTrading1
	Drop table #TempTrading
	Drop Table #TempTradingIndirectIncome
	Drop Table #TempTradingIndirectExpense
	Drop Table #TempTradingED
	Drop Table #TempTradingID


