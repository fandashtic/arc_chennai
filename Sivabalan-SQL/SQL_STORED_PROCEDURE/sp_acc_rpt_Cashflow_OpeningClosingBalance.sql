CREATE procedure sp_acc_rpt_Cashflow_OpeningClosingBalance (@parentid integer,@fromdate datetime, @todate datetime,@Opening Integer , @balance decimal(18,6) output)          
as          
Declare @GroupID int          
        
Set @balance=0          

Create Table #temp(GroupID int,          
     Status int)          
Insert into #temp select GroupID, 0 From AccountGroup          
Where ParentGroup = @parentid --and isnull(Active,0)=1          
Declare Parent Cursor Dynamic For          
Select GroupID From #temp --Where Status = 0          
Open Parent          
Fetch From Parent Into @GroupID          
While @@Fetch_Status = 0          
Begin          
 Insert into #temp           
 Select GroupID, 0 From AccountGroup          
 Where ParentGroup = @GroupID --and isnull(Active,0)=1          
 Fetch Next From Parent Into @GroupID          
End          
Close Parent          
DeAllocate Parent          

Declare @LastBalance decimal(18,6)
Declare @AccountBalance decimal(18,6)

Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6),@TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)          
Declare @AccountID Int,@Exists Int,@DepPercent Decimal(18,6),@DepAmount Decimal(18,6),@TotDepAmt Decimal(18,6)          
Declare @OPENINGSTOCK INT,@CLOSINGSTOCK Int,@DEPRECIATION Int,@FIXEDASSETS Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int          
SET @OPENINGSTOCK=22          
Set @CLOSINGSTOCK=23          
Set @DEPRECIATION=24          
Set @FIXEDASSETS=13          
Set @TAXONCLOSINGSTOCK=88          
Set @TAXONOPENINGSTOCK=89          
          
Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)          
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@APVBalanceAmt Decimal(18,6)          
--Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup          
Set @StrDate = dbo.sp_acc_getfiscalyearstart()          
Set @CheckDate =Cast(@StrDate As DateTime)          
set @CheckDate = DateAdd(m, 6, @CheckDate)          
set @CheckDate = DateAdd(s, 0-1, @CheckDate)          
          
insert into #temp values(@parentid,0)          
Declare scanrecursiveaccounts Cursor Keyset For          
Select AccountID from AccountsMaster where GroupID in (select groupid from #temp) --and isnull(Active,0)=1          
Open scanrecursiveaccounts          
Fetch From scanrecursiveaccounts Into @AccountID          
While @@Fetch_Status=0          
Begin          
	Set @AccountBalance=0
	If Not exists(Select top 1 openingvalue from AccountOpeningBalance where  OpeningDate=@fromdate and AccountID =@AccountID)          
		Begin          
			Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID -- and isnull(Active,0)=1          
		End          
	Else          
		Begin           
		   	set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID=@AccountID),0)          
		End          
	If @opening = 0
 		Begin
		   	set @Accountbalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
		   	where (dbo.stripdatefromtime(transactiondate) between @Fromdate and @todate) and           
		   	[AccountID] =@AccountID and documenttype not in 
			(27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)and 
			isnull(status,0) <> 128 and isnull(status,0) <> 192), 0)          
		   	Set @AccountBalance= @AccountBalance + @LastBalance
		End
	Else
		Begin
			set @AccountBalance = isnull(@LastBalance,0)
		End
	set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)          
	Set @AccountBalance=0          
	Fetch Next From scanrecursiveaccounts Into @AccountID          
End          
Set @balance=isnull(@balance,0)          
Close scanrecursiveaccounts          
DeAllocate scanrecursiveaccounts          
          
/*set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
where dbo.stripdatefromtime([TransactionDate]) between @fromdate and @todate and           
([AccountID] in (select [AccountID] from [AccountsMaster] where [GroupID] in (select groupid from #temp)))), 0)          
set @balance=@Balance + @LastBalance          
*/          
drop table #temp 

