CREATE procedure sp_acc_rpt_cashflowrecursivebalance(@parentid integer,@fromdate datetime, @todate datetime,@balance decimal(18,6) output,@drilldown integer = 0 )--,@TotalDepAmt decimal(18,6) = 0 Output)          
as  
DECLARE @STOCKINTRADE int          
SET @STOCKINTRADE =21          
Set @balance=0          
-- -- Set @TotalDepAmt=0      
Set Dateformat dmy
        
DECLARE @ToDatePair datetime        
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        

        
Create Table #temp(GroupID int,
     Status int)          
Declare @GroupID int          
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

Declare @TxnAmt decimal(18,6)
Declare @LastBalance decimal(18,6)          
Declare @AccountBalance decimal(18,6)          
Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6),@TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)          
Declare @AccountID Int,@Exists Int,@DepPercent Decimal(18,6),@DepAmount Decimal(18,6),@TotDepAmt Decimal(18,6)          
Declare @CLOSINGSTOCK Int,@DEPRECIATION Int,@FIXEDASSETS Int, @OPENINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int          
Set @CLOSINGSTOCK=23          
Set @DEPRECIATION=24          
Set @FIXEDASSETS=13          
SET @OPENINGSTOCK=22          
Set @TAXONCLOSINGSTOCK=88          
Set @TAXONOPENINGSTOCK=89          
          
Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)          
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@APVBalanceAmt Decimal(18,6)          
--Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup          
Set @StrDate= dbo.sp_acc_getfiscalyearstart()          
Set @CheckDate =Cast(@StrDate As DateTime)          
set @CheckDate = DateAdd(m, 6, @CheckDate)          
set @CheckDate = DateAdd(s, 0-1, @CheckDate)          

CREATE TABLE #GROUPBALANCE 
(
	GROUPID		NUMERIC(9),
	TRANSACTIOID NUMERIC(9),
	ACCOUNTID	NUMERIC(9),
	DEBIT decimal(18,6),
	CREDIT decimal(18,6)
)



declare @transactioNid numeric(9),@tempaccountid numeric(9),@debit decimal(18,6),@credit decimal(18,6)
declare @count numeric(18)

insert into #temp values(@parentid,0)          



if @drilldown = 0 
	Begin
		Declare scanrecursiveaccounts Cursor Keyset For          
		Select AccountID from AccountsMaster where GroupID in (select groupid from #temp) and    
		AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500) 
	End
Else if @drilldown = 1 
	Begin
		Declare scanrecursiveaccounts Cursor Keyset For          
		Select AccountID from AccountsMaster where accountid = @parentid and    
		AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500) 
	End
Open scanrecursiveaccounts          
Fetch From scanrecursiveaccounts Into @AccountID          
While @@Fetch_Status=0          
Begin      
	set @accountbalance = 0
-- -- -- 	if @accountid = 4
-- -- -- 		Begin
-- -- -- 			Declare Cursor1 cursor for
-- -- -- 			select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID

-- -- -- 			and transactionid in (select distinct transactionid from generaljournal where 
-- -- -- 			dbo.stripdatefromtime(transactiondate) between @fromdate and @todate
-- -- -- 			and accountid in (select distinct accountid from #Cash_Bank_IDS ))
-- -- -- 			and accountid not in (select distinct accountid from #Cash_Bank_IDS ) and isnull(status,0) <> 192
-- -- -- 			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) 
-- -- -- 			and isnull(status,0) <> 128
-- -- -- 		End
-- -- -- 	Else
-- -- -- 		Begin
-- -- 			select @accountid,'wanted'
-- -- -- 			select 'inside wanted',@accountid
-- -- -- 			select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
-- -- -- 			and transactionid in (select distinct transactionid from generaljournal where 
-- -- -- 			dbo.stripdatefromtime(transactiondate) between @fromdate and @todate and accountid in (select distinct accountid from #Cash_Bank_IDS) )
-- -- -- 			and accountid not in (select distinct accountid from #Cash_Bank_IDS where accountid <> 4) and status <> 192
-- -- -- 			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)

			Declare Cursor1 cursor for
			select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
			and transactionid in (select distinct transactionid from generaljournal where 
			dbo.stripdatefromtime(transactiondate) between @fromdate and @todate and accountid in (select distinct accountid from #Cash_Bank_IDS) )
			and accountid not in (select distinct accountid from #Cash_Bank_IDS ) and isnull(status,0) <> 192
			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
			and isnull(status,0) <> 128
-- -- -- 		end

	open cursor1
	Fetch from cursor1 into @transactionid,@debit,@credit

	while @@Fetch_status = 0
	Begin
		if  @debit <> 0 
		Begin
			select @count = count(1) from generaljournal where transactionid = @transactionid
			and credit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS )
			and isnull(status,0) <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
			and isnull(status,0) <> 128
			if @count > 0
				Begin

-- -- -- 					select * from generaljournal where transactionid = @transactionid
-- -- -- 					and credit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS where accountid <> 4)
-- -- -- 					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
-- -- -- 					set @AccountBalance = @AccountBalance - @txnamt

					select @txnamt = sum(credit) from generaljournal where transactionid = @transactionid
					and credit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS  )
					and isnull(status,0) <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
					and isnull(status,0) <> 128
					set @AccountBalance = @AccountBalance - @txnamt
				End
		End
		Else if @credit <> 0
		Begin
			select @count = count(1) from generaljournal where transactionid = @transactionid
			and debit <> 0 and accountid in (select distinct accountid from  #Cash_Bank_IDS )
			and isnull(status,0) <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
			and isnull(status,0) <> 128
			if @count > 0
				Begin
-- -- -- 					select * from generaljournal where transactionid = @transactionid
-- -- -- 					and debit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS where accountid <> 4)
-- -- -- 					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
-- -- -- 					set @accountbalance = @accountbalance + @txnamt


					select @txnamt = sum(debit) from generaljournal where transactionid = @transactionid
					and debit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS )
					and isnull(status,0) <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
					and isnull(status,0) <> 128
					set @accountbalance = @accountbalance + @txnamt
				End
		End
		Fetch from cursor1 into @transactionid,@debit,@credit		
	End
	close cursor1
	deallocate cursor1
   	Set @AccountBalance=isnull(@AccountBalance,0)
            
 	set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)          
 Fetch Next From scanrecursiveaccounts Into @AccountID          
End          
      
Close scanrecursiveaccounts          
DeAllocate scanrecursiveaccounts          
          
/*set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
where dbo.stripdatefromtime([TransactionDate]) between @fromdate and @todate and           
([AccountID] in (select [AccountID] from [AccountsMaster] where [GroupID] in (select groupid from #temp)))), 0)          
set @balance=@Balance + @LastBalance          
*/          
drop table #temp 










