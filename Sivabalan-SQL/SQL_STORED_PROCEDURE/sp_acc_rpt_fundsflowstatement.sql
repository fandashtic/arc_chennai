CREATE Procedure sp_acc_rpt_fundsflowstatement(@FromDate DateTime,@ToDate DateTime)
As

/* 
Purpose : 
To find How much Funds have flowed in and how effectively its been used

How to Separate Groups as Source and Application of Funds ?
Source:
1. 	Increase in Capital/Liabilities.(Any groups under Liabilities)
2. 	Decrease in Fixed Assets/Investments. (Any groups under Assets)
3. 	Funds from operations (+ve balance of P&L account)

Application:
1. 	Decrease in Capital/Liability. (Any groups under Liabilities)
2. 	Increase in Fixed Assets/Investments. (Any groups under Assets)
3. 	Funds from operations (-ve balance of P&L account)

Parameters Passed : 
From Date and To Date for which one has to analyze the In-Flow and Out-Flow of Funds

How is it done?
1. 	Basically to compare Two Balance Sheets of Given Dates
2. 	Find the Opening Balance for the Fromdate which is passed. 
	Use "sp_acc_rpt_FundsFlow_Recursivebalance" to find the opening balance.One has to pass 
	1 as the parameter if he has to find out the Opening Balance as on any date
3. 	Find the Closing Balance for the Todate which is passed. 
	Use "sp_acc_rpt_FundsFlow_Recursivebalance" to find the opening balance.One has to pass 
	0 as the parameter if he has to find out the Opening Balance as on any date
4.	Deduct Opening Balance from Closing Balance and basis the condition place it under 
	the respective groups
5.	Current Assets and Current Liabilities cannot be segregated as Source and Funds but 
	the difference has to put as Increase in Working Capital or Decrease in Working Capital
6.	Depreciation which is calculated has to be added back, as its a Non-Cash Item which 
	doesnt reduce the Funds
7. 	@Passedfromdate stores the default from date passed from frontend
8.	Use "sp_acc_rpt_TradingAC_FundsFlow" to find the Funds from operations.One has to pass 
	1 as the parameter if he has to find out the Opening Profit / Loss as on any date
9.	Use "sp_acc_rpt_TradingAC_FundsFlow" to find the Funds from operations.One has to pass 
	0 as the parameter if he has to find out the closing Profit / Loss as on any date

How to calculate Funds from Operations?
	Profit for the period 01/10/2004 : (10000)
	Profit for the period 01/10/2005 : (20000)
	Then Funds from operatios = Profit for the period 01/10/2005 - Profit for the period 01/10/2004 
	ie -20000 - (-10000) = -10000 which is a loss
	If the above value is + Ve then it is source else application
*/


DECLARE @balance decimal(18,6),@TotalDepAmt decimal(18,6),@GroupCode Int,@group nvarchar(300),@AccountType Int,@stockvalue decimal(18,6)
Declare @NEXTLEVEL INT,@LASTLEVEL INT
Declare @LEAFACCOUNT int
Declare @ACCOUNTGROUP int
Declare @CURRENTASSET int
Declare @SPECIALCASE3 INT
Declare @SetUpDate	Datetime



select @SetupDate = dbo.stripdatefromtime(OpeningDate) from setup

SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2 -- link value for account	
SET @ACCOUNTGROUP = 65 -- link value for sub groups
SET @CURRENTASSET =17 -- groupid of current asset
SET @SPECIALCASE3=6

Declare @NetDebit Decimal(18,6),@NetCredit Decimal(18,6)
Declare @Profit_Loss_FromDt Decimal(18,6)
Declare @Profit_Loss_ToDt Decimal(18,6)
Declare @DepAmtFromDt	Decimal(18,6)
Declare @DepAmtToDt	Decimal(18,6)
Declare @PassedFromDate Datetime

-- from date is changed inside the if condition , so set it to another variable and display it in frontend
set @PassedFromDate = @fromdate
if @setupdate <> @fromdate
	Begin
		-- basically to find out the Closing Balance of previous day , which is openingbalance of current day
		Set @fromdate = Dateadd(dd,-1,@fromdate)
	End


Create table #TempVAsset
(
AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,
AccountID Int null,FromDate datetime null,ToDate datetime null,
DocRef integer null,DocType integer null,HighLight Int null
)
Create table #TempVLiability
(
AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,
AccountID Int null,FromDate datetime null,ToDate datetime null,
DocRef integer null,DocType integer null,HighLight Int null
)
Create table #TempVerticalFromDt
(
AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,
AccountID Int null,FromDate datetime null,ToDate datetime null,
DocRef integer null,DocType integer null,HighLight Int null
)
Create table #TempVerticalToDt
(
AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,
AccountID Int null,FromDate datetime null,ToDate datetime null,
DocRef integer null,DocType integer null,HighLight Int null
)
Create table #TempVPL
(
AccountName nvarchar(300),Debit Decimal(18,6) null,Credit Decimal(18,6) null,
ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,
DocRef integer null,DocType integer null,ToMatch1 Int null,ToMatch2 Int null,
HighLight Int null
)

-- FOR FROMDATE
IF @setupdate <> @Passedfromdate
	Begin
		Insert Into #TempVPL(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
		Execute sp_acc_rpt_TradingAC_FundsFlow @SetupDate,@Fromdate,0,@PassedFromDate
	End
Else
	Begin
		Insert Into #TempVPL(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
		Execute sp_acc_rpt_TradingAC_FundsFlow @SetupDate,@FromDate,1,@PassedFromDate
	End

Select @NetDebit= case when Debit is Null  then  0 else Debit  end,
@NetCredit=case when Credit is Null  then  0 else Credit  end 
from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'

If @NetDebit<>0 
Begin
	Insert #TempVLiability
	Select dbo.LookupDictionaryItem('Profit for the Period',Default) ,@NetDebit,0,0,@SetupDate,@fromdate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'
	set @Profit_Loss_FromDt = Abs(ISNULL(@NetDebit,0))
End

If @NetCredit<>0 
Begin
	Insert #TempVAsset
	Select dbo.LookupDictionaryItem('Loss for the Period',Default) ,@NetCredit,0,0,@SetupDate,@fromdate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'
 	set @Profit_Loss_FromDt = ISNULL(@NetCredit,0) * -1
End

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
AccountType in (3,2,1) order by AccountType desc

OPEN scanrootlevel

FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType

WHILE @@FETCH_STATUS =0
BEGIN
	Set @balance=0
	if @setupdate <> @Passedfromdate
		Begin
-- -- 			execute sp_acc_rpt_recursivebalance @GroupCode,@SetupDate,@fromdate,@balance output,@TotalDepAmt output
			execute sp_acc_rpt_FundsFlow_Recursivebalance @GroupCode,@SetupDate,@fromdate,@balance output,@TotalDepAmt output ,0
		End
	Else
		Begin
			execute sp_acc_rpt_FundsFlow_Recursivebalance @GroupCode,@SetupDate,@Passedfromdate,@balance output,@TotalDepAmt output ,1
		End

    	If @AccountType=1
		Begin
		If @TotalDepAmt=0
		Begin
			Insert #TempVAsset
			Select @Group ,@balance,0,@GroupCode,@SetupDate,@fromdate,0,0,@ACCOUNTGROUP
		End
		Else
		Begin
			-- since Depreciration is a noncash item , it has to added back to the asset
			Insert #TempVAsset
			Select @Group ,@balance + @TotalDepAmt,0,@GroupCode,@SetupDate,@fromdate,0,0,@ACCOUNTGROUP
			set @Profit_Loss_FromDt = isnull(@Profit_Loss_FromDt ,0)
-- -- 			Insert #TempVAsset
-- -- 			Select @Group ,@balance ,0,@GroupCode,@SetupDate,@fromdate,0,0,@ACCOUNTGROUP
-- -- 			Set @DepAmtFromDt = @TotalDepAmt
-- -- 			set @Profit_Loss_FromDt = @Profit_Loss_FromDt + @TotalDepAmt
		End
	End
	Else if @AccountType=2 or @AccountType=3
	Begin
		Insert #TempVLiability
		Select @Group,case when @balance > 0 then (0-@Balance) else abs(@balance) end,0,@GroupCode,@SetupDate,@fromdate,0,0,@ACCOUNTGROUP
	End
	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel

Insert #TempVAsset
Select 'Total',Sum(Amount),0,0,@SetupDate,@fromdate,0,0,@LASTLEVEL from #TempVAsset

Insert #TempVLiability
Select 'Total',Sum(Amount),0,0,@SetupDate,@fromdate,0,0,@LASTLEVEL from #TempVLiability

Insert #TempVerticalFromDt
Select 'Assets',Null,0,0,@SetupDate,@fromdate,0,0,@LASTLEVEL

Insert #TempVerticalFromDt
Select * from #TempVAsset

Insert #TempVerticalFromDt
Select Null,Null,0,0,@SetupDate,@fromdate,0,0,@LASTLEVEL

Insert #TempVerticalFromDt
Select 'Liabilities',Null,0,0,@SetupDate,@fromdate,0,0,@LASTLEVEL

Insert #TempVerticalFromDt
Select * from #TempVLiability
--comment
-- -- Select 'Group Name'=AccountName, 'Amount'=Amount,ToMatch,AccountID,FromDate,ToDate,DocRef,DocType,HighLight,HighLight from #TempVerticalFromDt

Truncate Table #TempVPL
Truncate Table #TempVAsset
Truncate Table #TempVLiability

---------------------------------------------FOR TODATE--------------------------------------
Insert Into #TempVPL(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
Execute sp_acc_rpt_TradingAC_FundsFlow @SetUpDate,@Todate,0,@PassedFromDate -- Vertical format

Select @NetDebit= case when Debit is Null  then  0 else Debit  end,
@NetCredit=case when Credit is Null  then  0 else Credit  end 
from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'

If @NetDebit<>0 
Begin
	Insert #TempVLiability
	Select dbo.LookupDictionaryItem('Profit for the Period',Default) ,@NetDebit,0,0,@SetUpDate,@todate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'
	Set @Profit_Loss_ToDt = Abs(ISNULL(@NetDebit,0))
End

If @NetCredit<>0 
Begin
	Insert #TempVAsset
	Select dbo.LookupDictionaryItem('Loss for the Period',Default) ,@NetCredit,0,0,@SetUpDate,@todate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'
	Set @Profit_Loss_ToDt = ISNULL(@NetCredit,0) * -1
End

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
AccountType in (3,2,1) order by AccountType desc

OPEN scanrootlevel

FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType

WHILE @@FETCH_STATUS =0
BEGIN
	Set @balance=0

-- -- 	execute sp_acc_rpt_recursivebalance @GroupCode,@SetUpDate,@todate,@balance output,@TotalDepAmt output
	execute sp_acc_rpt_FundsFlow_Recursivebalance @GroupCode,@SetUpDate,@todate,@balance output,@TotalDepAmt output,0
    	If @AccountType=1
		Begin
		If @TotalDepAmt=0
		Begin
			Insert #TempVAsset
			Select @Group ,@balance,0,@GroupCode,@SetUpDate,@todate,0,0,@ACCOUNTGROUP
		End
		Else
		Begin
			-- since Depreciration is a noncash item , it has to added back to the asset
			Insert #TempVAsset
			Select @Group ,@balance + @TotalDepAmt ,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
			set @Profit_Loss_ToDt = ISNULL(@Profit_Loss_ToDt,0) -- + ISNULL(@TotalDepAmt,0)
-- -- -- 			Set @DepAmtToDt = @TotalDepAmt
		End
	End
	Else if @AccountType=2 or @AccountType=3
	Begin
		Insert #TempVLiability
		Select @Group,case when @balance > 0 then (0-@Balance) else abs(@balance) end,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
	End
	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel

Insert #TempVAsset
Select 'Total',Sum(Amount),0,0,@SetUpDate,@todate,0,0,@LASTLEVEL from #TempVAsset

Insert #TempVLiability
Select 'Total',Sum(Amount),0,0,@SetUpDate,@todate,0,0,@LASTLEVEL from #TempVLiability

Insert #TempVerticalToDt
Select 'Assets',Null,0,0,@SetUpDate,@todate,0,0,@LASTLEVEL

Insert #TempVerticalToDt
Select * from #TempVAsset

Insert #TempVerticalToDt
Select Null,Null,0,0,@SetUpDate,@todate,0,0,@LASTLEVEL

Insert #TempVerticalToDt
Select 'Liabilities',Null,0,0,@SetUpDate,@todate,0,0,@LASTLEVEL

Insert #TempVerticalToDt
Select * from #TempVLiability
--comment
-- -- Select 'Group Name'=AccountName, 'Amount'=Amount,ToMatch,AccountID,FromDate,ToDate,DocRef,DocType,HighLight,HighLight from #TempVerticalToDt

Drop Table #TempVPL
Drop Table #TempVAsset
Drop Table #TempVLiability

Create table #FundsFlow
(
AccountName nvarchar(300),Amount Decimal(18,6) null,TotalAmount Decimal(18,6) null,
ToMatch int null,AccountID Int null,FromDate datetime null,
ToDate datetime null,DocRef integer null,DocType integer null,
HighLight Int null
)

Declare @Capital 		Decimal(18,6)
Declare @BLongTerm		Decimal(18,6)
Declare @BShortTerm		Decimal(18,6)

Declare @Deposits 		Decimal(18,6)
Declare @Investments 	Decimal(18,6)
Declare @FA 			Decimal(18,6)
Declare @LoanAdvances 	Decimal(18,6)
Declare @Profit_Loss	Decimal(18,6)
Declare @TotSources		Decimal(18,6)
Declare @TotApps		Decimal(18,6)

set @Profit_Loss = isnull(@Profit_Loss_ToDt,0) - isnull(@Profit_Loss_FromDt ,0)

Select @Capital = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 1 and b.Accountid = 1

Select @Deposits = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 15 and b.Accountid = 15

Select @Investments = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 14 and b.Accountid = 14

-- -- Select @FA = (b.Amount - A.Amount) + @DepAmtFromDt + @DepAmtToDt from 
-- -- #TempVerticalFromDt a,#TempVerticalToDt b
-- -- where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
-- -- and a.accountid = 13 and b.Accountid = 13

Select @FA = (b.Amount - A.Amount) from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 13 and b.Accountid = 13
-- -- select @FA

Select @BLongTerm = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 3 and b.Accountid = 3

Select @BShortTerm = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 6 and b.Accountid = 6

Select @LoanAdvances = b.Amount - A.Amount from 
#TempVerticalFromDt a,#TempVerticalToDt b
where ltrim(rtrim(a.accountname)) = ltrim(rtrim(b.accountname))
and a.accountid = 16 and b.Accountid = 16

Insert into #FundsFlow (AccountName,FromDate,Todate,highlight)
Select 'Source of Funds',@Fromdate,@Todate,1

Set @TotSources	 = 0
-- if capital is increased then cash/funds has come in 
if @Capital >= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@Capital,0,1,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 1
		set @TotSources	= @TotSources + Abs(@Capital)
	End
-- if Borrowings is increased then borrowing shas been made an it has increased the funds 
if @BLongTerm >= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@BLongTerm,0,3,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 3
		set @TotSources	= @TotSources + Abs(@BLongTerm)
	End

if @BShortTerm >= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@BShortTerm,0,6,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 6
		set @TotSources	= @TotSources + Abs(@BShortTerm)
	End
-- if FA value goes down , then asset is sold and funds has increased
if @FA <= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@FA),0,13,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 13
		set @TotSources	= @TotSources + Abs(@FA)
	End
-- if Investments value goes down , then asset is sold and funds has increased
if @Investments <= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@Investments),0,14,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 14
		set @TotSources	= @TotSources + Abs(@Investments)
	End
-- if Deposits value goes down , then asset is sold and funds has increased
if @Deposits <= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@Deposits),0,15,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 15
		set @TotSources	= @TotSources + Abs(@Deposits)
	End
-- if Loans value goes down , then asset is sold and funds has increased
if @LoanAdvances <= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@LoanAdvances),0,16,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 16
		set @TotSources	= @TotSources + Abs(@LoanAdvances)
	End

/* How funds from operations is calculated ( -Ve indicates loss)
	Profit for the period 01/10/2004 : -10000
	Profit for the period 01/10/2005 : -20000
	Then Funds from operatios = Profit for the period 01/10/2005 - Profit for the period 01/10/2004 
	ie -20000 - (-10000) = -10000 which is a loss
	If the above value is + Ve then it is source else application
*/
if @Profit_Loss >= 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select dbo.LookupDictionaryItem('Funds from Operations',Default),@Profit_Loss,0,-1,@FromDate,@Todate,0,0,6
		set @TotSources	= @TotSources + Abs(@Profit_Loss)
	End


--INSERT THE TOTAL FOR SOURCE OF FUND
Insert into #Fundsflow(AccountName,Highlight) values(Null,1)
Insert into #Fundsflow(AccountName ,TotalAmount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
Select 'Total Sources (A)',@TotSources,0,0,@FromDate,@Todate,0,0,1
-------------------------------------------------------------------------------------------
Insert into #Fundsflow(AccountName,Highlight) values(Null,1)
Insert into #FundsFlow (AccountName,FromDate,Todate,Highlight)
Select 'Application of Funds',@Fromdate,@Todate,1

set @TotApps = 0
if @Capital < 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@Capital),0,1,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 1
		set @TotApps = @TotApps  + Abs(@Capital)
	End

if @BLongTerm < 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@BLongTerm),0,3,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 3
		set @TotApps = @TotApps  + Abs(@BLongTerm)
	End

if @BShortTerm < 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,ABS(@BShortTerm),0,6,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 6
		set @TotApps = @TotApps  + Abs(@BShortTerm)
	End

if @FA > 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@FA,0,13,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 13
		set @TotApps = @TotApps  + Abs(@FA)
	End

if @Investments > 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@Investments,0,14,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 14
		set @TotApps = @TotApps  + Abs(@Investments)
	End

if @Deposits > 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@Deposits,0,15,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 15
		set @TotApps = @TotApps  + Abs(@Deposits)
	End

if @LoanAdvances > 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select GroupName,@LoanAdvances,0,16,@FromDate,@Todate,0,0,@ACCOUNTGROUP from Accountgroup 
		where groupid = 16
		set @TotApps = @TotApps  + Abs(@LoanAdvances)
	End

if @Profit_Loss < 0
	Begin
		Insert into #FundsFlow (AccountName ,Amount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
		select dbo.LookupDictionaryItem('Funds from Operations',Default),Abs(@Profit_Loss),0,-1,@FromDate,@Todate,0,0,6
		set @TotApps = @TotApps  + Abs(@Profit_Loss)
	End

Insert into #Fundsflow(AccountName,Highlight) values(Null,1)
Insert into #Fundsflow(AccountName ,TotalAmount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)
Select 'Total Applications (B)',Abs(@TotApps),0,0,@FromDate,@Todate,0,0,1

Insert into #Fundsflow(AccountName,Highlight) values(Null,1)
Insert into #Fundsflow(AccountName ,TotalAmount ,ToMatch ,AccountID ,FromDate ,ToDate ,
			DocRef  ,DocType  ,HighLight)

Select 
Case 
	when (@TotSources - Abs(@TotApps)) < 0 then dbo.LookupDictionaryItem('Decrease in Working Capital (A-B)',Default)
	Else dbo.LookupDictionaryItem('Increase in Working Capital (A-B)',Default)
End
,Abs(@TotSources - Abs(@TotApps)),0,-2,@FromDate,@Todate,0,0,66

select 'Account Group'=AccountName ,'Total' = Amount ,'Total Amount'=TotalAmount ,
ToMatch ,AccountID ,@PassedFromDate,
@ToDate ,DocRef ,DocType ,
HighLight,Highlight  from #Fundsflow

Drop Table #TempVerticalFromDt
Drop Table #TempVerticalToDt





























