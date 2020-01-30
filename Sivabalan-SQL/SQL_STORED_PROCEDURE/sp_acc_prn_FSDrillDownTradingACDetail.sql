CREATE procedure sp_acc_prn_FSDrillDownTradingACDetail(@fromdate datetime,@todate datetime ,@parentid integer,@Hide0BalAC Int =0)
as        
DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)        
DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)        
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer        
DECLARE @balance decimal(18,6),@ConvertInfo Decimal(18,6)        
        
DECLARE @LEAFACCOUNT integer        
DECLARE @ACCOUNTGROUP integer        
DECLARE @NEXTLEVEL integer        
DECLARE @NONEXTLEVEL integer        
DECLARE @SPECIALCASE4 Integer        
      
DECLARE @ToDatePair datetime            
SET @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))            
      
SET @NEXTLEVEL =0        
SET @NONEXTLEVEL =1        
SET @LEAFACCOUNT =2        
SET @ACCOUNTGROUP =3        
SET @SPECIALCASE4=100        
        
Declare @DayCount int        
Set @DayCount=DateDiff(day,@FromDate,@ToDate)+1        
        
Declare @OpenDate DateTime -- Opening date from setup        
Select @OpenDate=dbo.stripdatefromtime(OpeningDate) from setup        
        
BEGIN        
 set @parentgroup1 = @parentid        
 create Table #TempRegister(GroupID integer,GroupName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)        
         
 DECLARE scanrootlevel CURSOR KEYSET FOR        
 select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1         
 OPEN scanrootlevel        
         
 FETCH FROM scanrootlevel into @groupid,@group        
         
 WHILE @@FETCH_STATUS =0        
  BEGIN        
     execute sp_acc_rpt_tradingacrecursivebalance @groupid,@fromdate,@todate,@balance output        
     INSERT INTO #TempRegister        
     SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then         
     @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP             
   FETCH NEXT FROM scanrootlevel into @groupid,@group        
  END        
 CLOSE scanrootlevel        
 DEALLOCATE scanrootlevel        
        
 Declare @AccountID Int,@AccountName nvarchar(50),@LastBalance Decimal(18,6)        
 Declare @DEPRECIATION Int,@FIXEDASSETS Int        
 Set @DEPRECIATION=24        
 Set @FIXEDASSETS=13        
        
 Declare @OPENINGSTOCK INT,@CLOSINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int        
 SET @OPENINGSTOCK=22        
 Set @CLOSINGSTOCK=23        
 Set @TAXONCLOSINGSTOCK=88        
 Set @TAXONOPENINGSTOCK=89        
        
 DECLARE scanbalancesheetaccounts CURSOR KEYSET FOR        
 select AccountID,AccountName from AccountsMaster where [GroupID]= @parentid --and isnull(Active,0)=1        
 OPEN scanbalancesheetaccounts        
 FETCH FROM scanbalancesheetaccounts into @AccountID,@AccountName        
 WHILE @@FETCH_STATUS=0        
 Begin        
  If @AccountID=@DEPRECIATION        
  Begin        
   execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@balance output        
   set @balance =isnull(@balance,0)        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,        
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End        
  Else If @AccountID=@OPENINGSTOCK        
  Begin        
   Select @balance=sum(opening_Value) from OpeningDetails where Opening_Date=@FromDate        
   set @balance =isnull(@balance,0)        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= abs(@balance),'Credit' = 0,        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End      
  Else If @AccountID=@TAXONOPENINGSTOCK        
  Begin        
   Select @balance =Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then        
   (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails where Opening_Date=@FromDate        
   set @balance =isnull(@balance,0)        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= abs(@balance), 'Credit' = 0,        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End        
  Else If @AccountID=@CLOSINGSTOCK        
  Begin        
   If @Todate<dbo.stripdatefromtime(getdate())        
   Begin        
    Select @balance=sum(opening_Value) from OpeningDetails where Opening_Date=dateadd(day,1,@ToDate)        
   End        
   Else        
   Begin        
    Set @balance=isnull(dbo.sp_acc_getclosingstock(),0)        
   End        
   set @balance =isnull(@balance,0)        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= 0,'Credit' = abs(@balance),        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End        
  Else If @AccountID=@TAXONCLOSINGSTOCK        
  Begin        
   If @Todate<dbo.stripdatefromtime(getdate())        
   Begin        
    Select @balance=Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then         
    (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails where Opening_Date=dateadd(day,1,@ToDate)        
   End        
   Else        
   Begin        
    Set @balance=isnull(dbo.sp_acc_getTaxonClosingStock(),0)        
   End        
   set @balance =isnull(@balance,0)        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= 0,        
   'Credit' = abs(@balance),        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End        
  Else        
  Begin        
   If @OpenDate=dbo.stripdatefromtime(@FromDate)        
   Begin        
      If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@FromDate and AccountID =@AccountID)  
      Begin  
        Select @LastBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID --and isnull(Active,0)=1  
      End  
      Else  
      Begin   
       set @LastBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate=@FromDate and AccountID =@AccountID),0)  
      End  
   End          
   set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal         
   where [TransactionDate] between @fromdate and @ToDatePair and [AccountID] = @AccountID and         
   documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)        
   set @balance=@balance + IsNull(@LastBalance,0)        
        
   INSERT #TempRegister        
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,        
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,        
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,        
   @fromdate,@todate,0,0,@LEAFACCOUNT         
  End        
  FETCH NEXT FROM scanbalancesheetaccounts into @AccountID,@AccountName        
 End        
 CLOSE scanbalancesheetaccounts        
 DEALLOCATE scanbalancesheetaccounts        
 If @Hide0BalAC = 0
 Begin
 	Select GroupName,IsNull(Debit,0) - IsNull(Credit,0) from #TempRegister         
 End
 Else
 Begin
 	Select GroupName,IsNull(Debit,0) - IsNull(Credit,0) from #TempRegister
	Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
 End
 Drop table #TempRegister        
END        


