CREATE Procedure sp_acc_rpt_TradingAC_FundsFlow(@FromDate DateTime, @Todate DateTime, @GetOpeningBalance integer , @PassedFromDate Datetime,@Hide0BalAC Int =0)
As
/*

Purpose : To find the Funds from Operations for the Given Date
1. If @OpeningBalance = 0 then get the Closing balance as on date
2. If @OpeningBalance = 1 then get the Opening balance as on date

*/

Declare @NEXTLEVEL INT,@LASTLEVEL INT,@LEAFACCOUNT INT,@ACCOUNTGROUP INT
Declare @PROFITANDLOSS INT
Declare @SALESACCOUNT INT
Declare @SPECIALCASE2 int
Declare @SPECIALCASE4 int
Declare @Balance Decimal(18,6),@GroupCode Int,@group nvarchar(25),@AccountType Int
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
SET @ACCOUNTGROUP =65
SET @SPECIALCASE2 =5
SET @SPECIALCASE4=100 -- Details of NetProfit

SET @PROFITANDLOSS=12
SET @SALESACCOUNT=28
Declare @VERTICALFORMAT Int
Declare @TFORMAT Int
Declare @NORMALFORMAT Int

Set @VERTICALFORMAT = 1
Set @TFORMAT = 2
Set @NORMALFORMAT = 3

Create table #TempTrading(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTrading1(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingED(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingID(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingInDirectIncome(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingInDirectExpense(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
	
Insert #TempTrading
Select 'Trading Account' ,Null, Null, Null,Null, Null, Null,Null,@LASTLEVEL

Set @Balance=0
execute sp_acc_rpt_tradingacrecursivebalancestock @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTradingED
Select dbo.LookupDictionaryItem('Opening Stock',Default),@Balance,Null,@OPENINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Opening Stock GroupID

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
AccountType in (4,5,6,7) order by AccountType desc,GroupID Desc
	
OPEN scanrootlevel

	FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			Set @Balance=0
			execute sp_acc_rpt_tradingacrecursivebalance_FundsFlow @GroupCode,@FromDate,@ToDate, @GetOpeningBalance,@Balance output
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
	
		FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel

	Set @Balance=0
	execute sp_acc_rpt_tradingacrecursivebalancestock @CLOSINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
	if @GetOpeningBalance = 1 --get only opening balance so , no closing stock
		Begin
			-- for opening trial balance bith opening an closing balance will be same so
			-- invoke the procedure again
			Set @Balance=0
			execute sp_acc_rpt_tradingacrecursivebalancestock @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
		End
	Insert #TempTradingID
	Select dbo.LookupDictionaryItem('Closing Stock',Default),Null,@Balance,@CLOSINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Closing Stock GroupID

	DECLARE scanrootlevel CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
	AccountType in (4) and GroupID <> @SALESACCOUNT order by AccountType desc,GroupID Desc
	
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @GroupCode <> @PROFITANDLOSS
		Begin
			Set @Balance=0
			execute sp_acc_rpt_tradingacrecursivebalance_FundsFlow @GroupCode,@FromDate,@ToDate,@GetOpeningBalance,@Balance output
			Insert #TempTradingID
			Select @Group,Null,case when IsNull(@Balance,0)<0 then abs(IsNull(@Balance,0)) else (0-IsNull(@Balance,0)) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
		End	
	
		FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
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
	Select AccountName, case when Debit is Null then Credit else Null end,case when Debit is not Null then Debit else Null end,Null,Null,Null,NUll,NUll,@LASTLEVEL from #TempTrading where AccountName=N'Gross Loss' or AccountName=N'Gross Profit'
	
	Insert #TempTrading1
	Select  * from #TempTradingIndirectIncome
	Insert #TempTrading1
	Select  * from #TempTradingIndirectExpense

	Select @OrganisationType=OrganisationType from Setup
	If @OrganisationType=2--Partnership
	Begin
		Insert #TempTrading1
		Select case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then 'Net Loss' else 'Net Profit' end,
		case when Sum(isnull(Debit,0)-isnull(Credit,0)) < 0 then abs(Sum(isnull(Debit,0)-isnull(Credit,0))) else Null end,
		case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then Sum(isnull(Debit,0)-isnull(Credit,0)) else Null end,0,@FromDate,@ToDate,0,0,@SPECIALCASE4 from #TempTrading1
	End
	Else
	Begin
		Insert #TempTrading1
		Select case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then 'Net Loss' else 'Net Profit' end,
		case when Sum(isnull(Debit,0)-isnull(Credit,0)) < 0 then abs(Sum(isnull(Debit,0)-isnull(Credit,0))) else Null end,
		case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then Sum(isnull(Debit,0)-isnull(Credit,0)) else Null end,Null,Null,Null,Null,Null,@LASTLEVEL from #TempTrading1
	End	
	Insert #TempTrading1
	Select 'Total' ,Sum(Debit), Sum(Credit), Null,Null,Null,Null,Null, @LASTLEVEL from #TempTrading1
	
	Insert #TempTrading
	Select * from #TempTrading1

	If @Hide0BalAC =0
	Begin
		Select "Group Name" = AccountName ,Debit ,Credit , 0,AccountID ,@PassedFromDate ,
		ToDate ,DocRef ,DocType ,HighLight, (isnull(Debit,0)-isnull(Credit,0)),HighLight  
		from #TempTrading
	End
	Else
	Begin
		Select "Group Name" = AccountName ,Debit ,Credit , 0,AccountID ,@PassedFromDate ,
		ToDate ,DocRef ,DocType ,HighLight, (isnull(Debit,0)-isnull(Credit,0)),HighLight  
		from #TempTrading
		Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(HighLight,0) in (1,65))
	End

	Drop Table #TempTrading1
	Drop table #TempTrading
	Drop Table #TempTradingIndirectIncome
	Drop Table #TempTradingIndirectExpense
	Drop Table #TempTradingED
	Drop Table #TempTradingID















