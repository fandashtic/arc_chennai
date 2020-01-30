CREATE Procedure [dbo].[sp_acc_con_rpt_TradingACTShape](@FromDate DateTime, @Todate DateTime)
As
Declare @NEXTLEVEL INT,@LASTLEVEL INT,@LEAFACCOUNT INT,@ACCOUNTGROUP INT
Declare @PROFITANDLOSS INT
Declare @SALESACCOUNT INT
Declare @SPECIALCASE2 int
Declare @SPECIALCASE4 int
Declare @Balance Decimal(18,2),@GroupCode Int,@group nvarchar(25),@AccountType Int
Declare @OrganisationType Int

SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2
SET @ACCOUNTGROUP =3
SET @SPECIALCASE2 =5
SET @SPECIALCASE4=100

SET @PROFITANDLOSS=12
SET @SALESACCOUNT=28

DECLARE @OPENINGSTOCKGROUP INT,@CLOSINGSTOCKGROUP Int
SET @OPENINGSTOCKGROUP=54
Set @CLOSINGSTOCKGROUP=55


Create table #TempTradingT(Debit nvarchar(25),EAmount Decimal(18,2),EAccountID Int,
Credit nvarchar(50),IAmount Decimal(18,2),IAccountID Int,
FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)


Create table #TempTrading(Expense nvarchar(25),EAmount Decimal(18,2),EAccountID Int,
Income nvarchar(50),IAmount Decimal(18,2),IAccountID Int,
FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)

Create table #TempTrading1(Expense nvarchar(25),EAmount Decimal(18,2),EAccountID Int,
Income nvarchar(50),IAmount Decimal(18,2),IAccountID Int,
FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)

Create table #TempTradingED(AccountName nvarchar(25),Amount Decimal(18,2),SNo Int IDENTITY(1,1),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingID(AccountName nvarchar(25),Amount Decimal(18,2),SNo Int IDENTITY(1,1),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
--Create table #TempTradingInDirect(AccountName varchar(25),Debit Decimal(18,2),Credit Decimal(18,2),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingEID(AccountName nvarchar(25),Amount Decimal(18,2),SNo Int IDENTITY(1,1),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTradingIID(AccountName nvarchar(25),Amount Decimal(18,2),SNo Int IDENTITY(1,1),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)

Insert #TempTradingT
Select 'Trading Account' ,Null, Null, Null,Null, Null, Null,Null,Null,Null,@LASTLEVEL

Set @Balance=0
execute sp_acc_con_rpt_tradingacrecursivebalancestock @OPENINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTradingED
Select 'Opening Stock',@Balance,@OPENINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Opening Stock GroupID

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from ConsolidateAccountGroup where ParentGroup=0 and 
AccountType in (4,5,6,7) order by AccountType desc,GroupID desc

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
			Select @Group,@Balance,@GroupCode,@FromDate,@ToDate,0,0,@ACCOUNTGROUP 
		end
		Else If @AccountType=4
		Begin
			If @GroupCode=@SalesAccount
			Begin
				Insert #TempTradingID
				Select @Group,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
			End
		end
		Else If @AccountType=5
		Begin
			Insert #TempTradingIID
			Select  @Group,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
		end
		Else If @AccountType=7
		Begin
			Insert #TempTradingEID
			Select @Group,@Balance,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
		end
	End	

	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel

Set @Balance=0
execute sp_acc_con_rpt_tradingacrecursivebalancestock @CLOSINGSTOCKGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTradingID
Select 'Closing Stock',@Balance,@CLOSINGSTOCKGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP -- Closing Stock GroupID

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from ConsolidateAccountGroup where ParentGroup=0 and 
AccountType in (4) and GroupID<>@SALESACCOUNT order by AccountType desc,GroupID desc

OPEN scanrootlevel

FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType

WHILE @@FETCH_STATUS =0
BEGIN
	If @GroupCode <> @PROFITANDLOSS
	Begin
		Set @Balance=0
		execute sp_acc_con_rpt_tradingacrecursivebalance @GroupCode,@FromDate,@ToDate,@Balance output
	
-- 		If @AccountType=6
-- 		Begin
-- 			Insert #TempTradingED
-- 			Select @Group,@Balance,@GroupCode,@FromDate,@ToDate,0,0,@ACCOUNTGROUP 
-- 		end
-- 		Else If @AccountType=4
-- 		Begin
--			If @GroupCode=@SalesAccount
--			Begin
				Insert #TempTradingID
				Select @Group,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@GroupCode,@FromDate,@Todate,0,0,@ACCOUNTGROUP 
--			End
-- 		end
-- 		Else If @AccountType=5
-- 		Begin
-- 			Insert #TempTradingIID
-- 			Select  @Group,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
-- 		end
-- 		Else If @AccountType=7
-- 		Begin
-- 			Insert #TempTradingEID
-- 			Select @Group,@Balance,@GroupCode,@Fromdate,@Todate,0,0,@ACCOUNTGROUP
-- 		end
	End	

	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel


Declare @ExpenseCount Int,@IncomeCount Int

Select @ExpenseCount=Count(*) from #TempTradingED
Select @IncomeCount=Count(*) from #TempTradingID
If @ExpenseCount =@IncomeCount 
Begin
	Insert #TempTrading
	Select #TempTradingED.AccountName,#TempTradingED.Amount,#TempTradingED.AccountID,
	#TempTradingID.AccountName,#TempTradingID.Amount,#TempTradingID.AccountID,
	#TempTradingID.FromDate,#TempTradingID.ToDate,#TempTradingID.DocRef,#TempTradingID.DocType,#TempTradingID.HighLight
	from #TempTradingED,#TempTradingID where #TempTradingED.SNO=#TempTradingID.SNO
End
If @ExpenseCount >@IncomeCount 
Begin
	Insert #TempTrading
	Select #TempTradingED.AccountName,#TempTradingED.Amount,#TempTradingED.AccountID,
	#TempTradingID.AccountName,#TempTradingID.Amount,#TempTradingID.AccountID,
	#TempTradingED.FromDate,#TempTradingED.ToDate,#TempTradingED.DocRef,#TempTradingED.DocType,#TempTradingED.HighLight
	from 
	#TempTradingED
	Left Join #TempTradingID on #TempTradingED.SNO = #TempTradingID.SNO
	--#TempTradingED,#TempTradingID where #TempTradingED.SNO *= #TempTradingID.SNO
End
If @ExpenseCount <@IncomeCount 
Begin
	Insert #TempTrading
	Select #TempTradingED.AccountName,#TempTradingED.Amount,#TempTradingED.AccountID,
	#TempTradingID.AccountName,#TempTradingID.Amount,#TempTradingID.AccountID,
	#TempTradingID.FromDate,#TempTradingID.ToDate,#TempTradingID.DocRef,#TempTradingID.DocType,#TempTradingID.HighLight
	from 
	#TempTradingED 
	Right Join #TempTradingID on #TempTradingED.SNO = #TempTradingID.SNO
	--#TempTradingED,#TempTradingID where #TempTradingED.SNO =* #TempTradingID.SNO
End

Insert #TempTradingT
Select  * from #TempTrading

Declare @DebitTotal Decimal(18,2),@CreditTotal Decimal(18,2),@GrossValue Decimal(18,2)
Select @DebitTotal=sum(isnull(Amount,0)) from #TempTradingED
Select @CreditTotal=sum(isnull(Amount,0)) from #TempTradingID
Set @GrossValue=@DebitTotal-@CreditTotal

Insert #TempTradingT
Select case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else 'Gross Profit' end,
case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else abs(isnull(@DebitTotal,0)-isnull(@CreditTotal,0)) end,Null,
case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then 'Gross Loss' else Null end,
case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then isnull(@DebitTotal,0)-isnull(@CreditTotal,0) else Null end,Null,
Null,Null,Null,NUll,@LASTLEVEL 


Insert #TempTradingT
Select 'Total',Sum(EAmount),0,'',Sum(IAmount),0,@FromDate,@Todate,0,0,@LASTLEVEL from #TempTradingT

Insert #TempTrading1
Select case when isnull(@GrossValue,0) > 0 then 'Gross Loss' else Null end,
case when isnull(@GrossValue,0) > 0 then @GrossValue else Null end,Null,
case when isnull(@GrossValue,0) > 0 then Null else 'Gross Profit' end,
case when isnull(@GrossValue,0) > 0 then Null else abs(@GrossValue) end,Null,
Null,Null,Null,NUll,@LASTLEVEL 

/*If @GrossValue>0 then
Begin
	Insert #TempTradingEID
	Select 'Gross Loss',@GrossValue,Null,@Fromdate,@Todate,0,0,@LASTLEVEL

End
Else If @GrossValue<0 then
Begin
	Insert #TempTradingIID
	Select 'Gross Profit',Abs(@GrossValue),Null,@Fromdate,@Todate,0,0,@LASTLEVEL

End
*/

Declare @ExpenseIDCount Int,@IncomeIDCount Int

Select @ExpenseIDCount=Count(*) from #TempTradingEID
Select @IncomeIDCount=Count(*) from #TempTradingIID
If @ExpenseIDCount =@IncomeIDCount 
Begin
	Insert #TempTrading1
	Select #TempTradingEID.AccountName,#TempTradingEID.Amount,#TempTradingEID.AccountID,
	#TempTradingIID.AccountName,#TempTradingIID.Amount,#TempTradingIID.AccountID,
	#TempTradingIID.FromDate,#TempTradingIID.ToDate,#TempTradingIID.DocRef,#TempTradingIID.DocType,#TempTradingIID.HighLight
	from #TempTradingEID,#TempTradingIID where #TempTradingEID.SNO=#TempTradingIID.SNO
End
If @ExpenseIDCount >@IncomeIDCount 
Begin
	Insert #TempTrading1
	Select #TempTradingEID.AccountName,#TempTradingEID.Amount,#TempTradingEID.AccountID,
	#TempTradingIID.AccountName,#TempTradingIID.Amount,#TempTradingIID.AccountID,
	#TempTradingEID.FromDate,#TempTradingEID.ToDate,#TempTradingEID.DocRef,#TempTradingEID.DocType,#TempTradingEID.HighLight
	from 
	#TempTradingEID
	Left Join #TempTradingIID on #TempTradingEID.SNO = #TempTradingIID.SNO
	--#TempTradingEID,#TempTradingIID where #TempTradingEID.SNO *= #TempTradingIID.SNO
End
If @ExpenseIDCount <@IncomeIDCount 
Begin
	Insert #TempTrading1
	Select #TempTradingEID.AccountName,#TempTradingEID.Amount,#TempTradingEID.AccountID,
	#TempTradingIID.AccountName,#TempTradingIID.Amount,#TempTradingIID.AccountID,
	#TempTradingIID.FromDate,#TempTradingIID.ToDate,#TempTradingIID.DocRef,#TempTradingIID.DocType,#TempTradingIID.HighLight
	from 
	#TempTradingEID
	Right Join #TempTradingIID on #TempTradingEID.SNO = #TempTradingIID.SNO
	--#TempTradingEID,#TempTradingIID where #TempTradingEID.SNO =* #TempTradingIID.SNO
End


Select @DebitTotal=Sum(isnull(EAmount,0)),@CreditTotal=Sum(isnull(IAmount,0)) from #TempTrading1

Select @OrganisationType=OrganisationType from Setup
If @OrganisationType=2--Partnership
Begin
	Insert #TempTrading1
	Select case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else 'Net Profit' end,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else abs(isnull(@DebitTotal,0)-isnull(@CreditTotal,0)) end,0,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then 'Net Loss' else Null end,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then isnull(@DebitTotal,0)-isnull(@CreditTotal,0) else Null end,0,
	@FromDate,@ToDate,0,0,@SPECIAlCASE4
End
Else
Begin
	Insert #TempTrading1
	Select case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else 'Net Profit' end,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then Null else abs(isnull(@DebitTotal,0)-isnull(@CreditTotal,0)) end,Null,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then 'Net Loss' else Null end,
	case when isnull(@DebitTotal,0)-isnull(@CreditTotal,0) > 0 then isnull(@DebitTotal,0)-isnull(@CreditTotal,0) else Null end,Null,
	Null,Null,Null,NUll,@LASTLEVEL
End

Insert #TempTradingT
Select Null ,Null, Null, Null, Null,Null,NUll,NUll,Null,Null,@LASTLEVEL

Insert #TempTradingT
Select 'P & L Account' ,Null, Null, Null,Null,Null,NUll,NUll,Null,Null,@LASTLEVEL

Insert #TempTradingT
Select  * from #TempTrading1

Insert #TempTradingT
Select 'Total',Sum(EAmount),0,'',Sum(IAmount),0,@FromDate,@Todate,0,0,@LASTLEVEL from #TempTrading1



Select "Expense" = Debit ,'Amount'=EAmount ,EAccountID,"Income" = Credit ,'Amount'=IAmount ,IAccountID ,
FromDate ,ToDate ,DocRef ,DocType ,HighLight,(IsNull(EAmount,0)-IsNull(IAmount,0)),HighLight from #TempTradingT

Drop Table #TempTrading1
Drop table #TempTrading
Drop table #TempTradingT
Drop Table #TempTradingED
Drop Table #TempTradingID
Drop Table #TempTradingEID
Drop Table #TempTradingIID

