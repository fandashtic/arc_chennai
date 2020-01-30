CREATE procedure sp_acc_con_prn_FSDrillDownBalanceSheet(@fromdate datetime,@todate datetime ,@parentid integer)  
as  
DECLARE @debit decimal(18,2),@credit decimal(18,2),@account nvarchar(30),@group nvarchar(50)  
DECLARE @totaldebit decimal(18,2),@totalcredit decimal(18,2)  
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer  
DECLARE @balance decimal(18,2),@LastBalance Decimal(18,2),@TotalDepAmt Decimal(18,2)  
DECLARE @stockvalue decimal(18,2)  
Declare @ConvertInfo decimal(18,2)  
DECLARE @CURRENTASSET int  
DECLARE @SPECIALCASE2 int  
DECLARE @SPECIALCASE3 int  
DECLARE @SPECIALCASE4 int  
DECLARE @LEAFACCOUNT integer  
DECLARE @ACCOUNTGROUP integer  
DECLARE @NEXTLEVEL integer  
DECLARE @NONEXTLEVEL integer  
  
SET @NEXTLEVEL =0  
SET @NONEXTLEVEL =1  
SET @LEAFACCOUNT =2  
SET @ACCOUNTGROUP =3  
  
SET @CURRENTASSET =17 -- groupid of current asset  
SET @SPECIALCASE2 =5 -- to restrict the link report for the stockvalue  
SET @SPECIALCASE3 =6 --Link to the Trading and P & L A/C  
SET @SPECIALCASE4 =7 --Link to the Share details of partners  
  
Declare @OPENINGSTOCK Int  
Declare @CLOSINGSTOCK Int  
Declare @DEPRECIATION Int  
Declare @FIXEDASSETS Int  
Declare @TAXONCLOSINGSTOCK Int  
Declare @TAXONOPENINGSTOCK Int  
Set @FIXEDASSETS=13  
SET @OPENINGSTOCK=22  
SET @CLOSINGSTOCK = 23  
Set @DEPRECIATION=24  
Set @TAXONCLOSINGSTOCK=88  
Set @TAXONOPENINGSTOCK=89  
  
DECLARE @OPENINGSTOCKGROUP INT,@CLOSINGSTOCKGROUP Int  
SET @OPENINGSTOCKGROUP=54  
Set @CLOSINGSTOCKGROUP=55  
  
Declare @TranID1 Int, @Debit1 Decimal(18,2), @Credit1 Decimal(18,2), @TotalDebit1 Decimal(18,2), @TotalCredit1 Decimal(18,2)  
  
BEGIN  
 set @parentgroup1 = @parentid  
   
 create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,2),Credit decimal(18,2),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)  
   
 DECLARE scanrootlevel CURSOR KEYSET FOR  
 select [GroupID],[GroupName]  from ConsolidateAccountGroup where [ParentGroup]=@parentgroup1   
 and GroupID<>54 --Opening Stock group  
   
 OPEN scanrootlevel  
   
 FETCH FROM scanrootlevel into @groupid,@group  
   
 WHILE @@FETCH_STATUS =0  
 BEGIN  
    
    execute sp_acc_con_rpt_recursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output  
    If @TotalDepAmt=0  
  Begin     
       INSERT INTO #TempRegister  
       SELECT 'Group ID'= @groupid,'Group Name'=@group,'Debit'= CASE WHEN ((@balance)> 0) then   
       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP       
  End   
  Else  
  Begin  
       INSERT INTO #TempRegister  
       SELECT 'Group ID'= @groupid,'Group Name'=@group + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then   
       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP       
  End  
    FETCH NEXT FROM scanrootlevel into @groupid,@group  
 END  
 CLOSE scanrootlevel  
 DEALLOCATE scanrootlevel  
  
 Declare @AccountID Int,@AccountName nvarchar(50)  
 Declare @DepAmount Decimal(18,2), @Exists Int  
  
 DECLARE scanbalancesheetaccounts CURSOR KEYSET FOR  
 select AccountID,AccountName from ConsolidateAccount where [GroupID]= @parentid  
 and AccountID not in (@OPENINGSTOCK,@TAXONOPENINGSTOCK)  
 OPEN scanbalancesheetaccounts  
 FETCH FROM scanbalancesheetaccounts into @AccountID,@AccountName  
 WHILE @@FETCH_STATUS=0  
 Begin  
  -- Depreciation value deducted from fixed Assest leaf account  
  Exec sp_acc_con_rpt_fixedAssetrecursive @AccountID,@Exists output  
  If @Exists=1  
  Begin  
   Select @balance= isNull(ClosingBalance,0),@DepAmount=IsNull(Depreciation,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1  
   Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)  
  
   INSERT #TempRegister  
   select 'Group ID'= @AccountID,'Group Name'= @AccountName + N' less depreciation value ' + cast(@DepAmount as nvarchar(50)),  
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,  
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,  
   @fromdate,@todate,0,0,@SPECIALCASE2   
  End  
  Else  
  Begin  
   Select @balance= isNull(ClosingBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1   Set @AccountBalance=@AccountBalance+@LastBalance  
  
   INSERT #TempRegister  
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,  
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,  
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,  
   @fromdate,@todate,0,0,@SPECIALCASE2  
  End  
  FETCH NEXT FROM scanbalancesheetaccounts into @AccountID,@AccountName  
 End  
 CLOSE scanbalancesheetaccounts  
 DEALLOCATE scanbalancesheetaccounts  
  
 select GroupName,IsNull(Debit,0)-IsNull(Credit,0) from #TempRegister   
 Drop table #TempRegister  
END  

