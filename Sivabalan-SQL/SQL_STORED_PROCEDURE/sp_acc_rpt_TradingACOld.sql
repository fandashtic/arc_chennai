CREATE Procedure sp_acc_rpt_TradingACOld(@FromDate DateTime, @Todate DateTime)
As
Declare @NEXTLEVEL INT,@LASTLEVEL INT,@PURCHASEGROUP INT,@DIRECTEXPENSEGROUP INT,@SALESGROUP INT,@DIRECTINCOMEGROUP INT
Declare @INDIRECTEXPENSEGROUP INT, @INDIRECTINCOMEGROUP INT,@LEAFACCOUNT INT,@ACCOUNTGROUP INT
Declare @SPECIALCASE2 int
Declare @Balance Decimal(18,6)

SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2
SET @ACCOUNTGROUP =3
SET @SPECIALCASE2 =5

SET @PURCHASEGROUP=27
SET @DIRECTEXPENSEGROUP=24
SET @SALESGROUP=28
SET @DIRECTINCOMEGROUP=26
SET @INDIRECTEXPENSEGROUP=25
SET @INDIRECTINCOMEGROUP =31

Create table #TempTrading(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Create table #TempTrading1(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,HighLight Int)
Insert #TempTrading
Select 'Trading Account' ,Null, Null, Null,Null, Null, Null,Null,@LASTLEVEL
Insert #TempTrading
Select dbo.LookupDictionaryItem('Opening Stock',Default),sum(opening_Value),Null,Null,Null, Null, Null,Null,@SPECIALCASE2 from OpeningDetails where Opening_Date=@FromDate
Insert #TempTrading
Select dbo.LookupDictionaryItem('Tax on Opening Stock',Default),sum(TaxSuffered_Value),Null,Null,Null, Null, Null,Null,@SPECIALCASE2 from OpeningDetails where Opening_Date=@FromDate

Set @Balance=0
execute sp_acc_rpt_recursivebalance @PURCHASEGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTrading
Select dbo.LookupDictionaryItem('Purchases',Default),@Balance,Null,@PURCHASEGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP 

Set @Balance=0
execute sp_acc_rpt_recursivebalance @DIRECTEXPENSEGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTrading
Select dbo.LookupDictionaryItem('Expenses (Direct)',Default),@Balance,Null,@DIRECTEXPENSEGROUP,@FromDate,@ToDate,0,0,@ACCOUNTGROUP

If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
Begin
	Insert #TempTrading
	Select dbo.LookupDictionaryItem('Closing Stock',Default),Null,sum(opening_Value),Null,Null,Null,NUll,NUll,@SPECIALCASE2 from OpeningDetails 
	where Opening_Date=dateadd(day,1,@ToDate)
End
Else
Begin
	Insert #TempTrading
	Select dbo.LookupDictionaryItem('Closing Stock',Default),Null,sum(Quantity*PurchasePrice),Null,Null,Null,NUll,NUll,@SPECIALCASE2 from Batch_Products
End

Set @Balance=0
execute sp_acc_rpt_recursivebalance @SALESGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTrading
Select dbo.LookupDictionaryItem('Sales',Default),Null,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@SALESGROUP,@FromDate,@Todate,0,0,@ACCOUNTGROUP 

Set @Balance=0
execute sp_acc_rpt_recursivebalance @DIRECTINCOMEGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTrading
Select dbo.LookupDictionaryItem('Income (Direct)',Default),Null,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@DIRECTINCOMEGROUP,@Fromdate,@ToDate,0,0,@ACCOUNTGROUP

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

Set @Balance=0
execute sp_acc_rpt_recursivebalance @INDIRECTINCOMEGROUP,@FromDate,@ToDate,@Balance output
Insert #TempTrading1
Select dbo.LookupDictionaryItem('Income (Indirect)',Default),Null,case when @Balance<0 then abs(@Balance) else (0-@Balance) end,@INDIRECTINCOMEGROUP,@Fromdate,@Todate,0,0,@ACCOUNTGROUP

--Declare @DepValue Decimal(18,6),@FIXEDASSETS Int
--Set @FIXEDASSETS=13
Set @Balance=0
execute sp_acc_rpt_recursivebalance @INDIRECTEXPENSEGROUP,@FromDate,@ToDate,@Balance output
--execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@DepValue output
--Set @Balance=isnull(@Balance,0)+isnull(@DepValue,0) --Depreciation value added
Insert #TempTrading1
Select dbo.LookupDictionaryItem('Expense (Indirect)',Default),@Balance,Null,@INDIRECTEXPENSEGROUP,@Fromdate,@Todate,0,0,@ACCOUNTGROUP

Insert #TempTrading1
Select case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then 'Net Loss' else 'Net Profit' end,
case when Sum(isnull(Debit,0)-isnull(Credit,0)) < 0 then abs(Sum(isnull(Debit,0)-isnull(Credit,0))) else Null end,
case when Sum(isnull(Debit,0)-isnull(Credit,0)) > 0 then Sum(isnull(Debit,0)-isnull(Credit,0)) else Null end,Null,Null,Null,Null,Null,@LASTLEVEL from #TempTrading1

Insert #TempTrading1
Select 'Total' ,Sum(Debit), Sum(Credit), Null,Null,Null,Null,Null, @LASTLEVEL from #TempTrading1

Insert #TempTrading
Select * from #TempTrading1

Select "Group Name" = AccountName ,Debit ,Credit , 0,AccountID ,FromDate ,ToDate ,DocRef ,DocType ,HighLight, HighLight  from #TempTrading
Drop Table #TempTrading1
Drop table #TempTrading

