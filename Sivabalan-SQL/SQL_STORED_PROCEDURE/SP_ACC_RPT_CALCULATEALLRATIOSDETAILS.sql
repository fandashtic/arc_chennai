CREATE Procedure SP_ACC_RPT_CALCULATEALLRATIOSDETAILS  
 (  
  @fromdate  datetime,  
  @todate  datetime ,  
  @parentid   integer,  
  @docref  integer,  
  @doctype  integer,  
  @mode   integer,  
  @Info   nvarchar(4000) = Null,  
  @State  Int=0  
 )          
as          
DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)          
DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
DECLARE @balance decimal(18,6),@LastBalance Decimal(18,6),@TotalDepAmt Decimal(18,6)          
DECLARE @stockvalue decimal(18,6)          
Declare @ConvertInfo decimal(18,6)          
DECLARE @CURRENTASSET int          
DECLARE @SPECIALCASE2 int          
DECLARE @SPECIALCASE3 int          
DECLARE @SPECIALCASE4 int          
DECLARE @LEAFACCOUNT integer          
DECLARE @ACCOUNTGROUP integer          
DECLARE @NEXTLEVEL integer          
DECLARE @NONEXTLEVEL integer          
          
DECLARE @ToDatePair datetime          
Set @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))          
        
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
          
Declare @TranID1 Int, @Debit1 Decimal(18,6), @Credit1 Decimal(18,6), @TotalDebit1 Decimal(18,6), @TotalCredit1 Decimal(18,6)          
          
IF @mode = @ACCOUNTGROUP or (@Mode = @SPECIALCASE3 and @parentid<>0)          
BEGIN          
 set @parentgroup1 = @parentid          
--  create Table #TempRegister(GroupID integer,GroupName varchar(255),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)          
 DECLARE scanrootlevel CURSOR dynamic FOR          
 select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1           
 and Active=1 and GroupID<>54 --Opening Stock group          
           
 OPEN scanrootlevel          
           
 FETCH FROM scanrootlevel into @groupid,@group          
           
 WHILE @@FETCH_STATUS =0          
 BEGIN          
      execute sp_acc_rpt_recursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output          
      If @TotalDepAmt=0          
  Begin             
       INSERT INTO #TempRegister          
       SELECT 'Group ID'= @groupid,'Group Name'=@group,'Debit'= CASE WHEN ((@balance)> 0) then           
       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP               
  End           
  Else          
  Begin          
       INSERT INTO #TempRegister          
       SELECT 'Group ID'= @groupid,'Group Name'=@group + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then           
       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP       
  End          
    FETCH NEXT FROM scanrootlevel into @groupid,@group          
 END          
 CLOSE scanrootlevel          
 DEALLOCATE scanrootlevel          
          
 Declare @AccountID Int,@AccountName nvarchar(50)          
 Declare @DepPercent Decimal(18,6), @DepAmount Decimal(18,6), @Exists Int          
          
 Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)          
 Declare @CheckDate as datetime,@StrDate as nvarchar(255), @APVBalanceAmt as Decimal(18,6)          
-- Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup          
 Set @StrDate= dbo.sp_acc_getfiscalyearstart()          
 Set @CheckDate =Cast(@StrDate As DateTime)          
 set @CheckDate = DateAdd(m, 6, @CheckDate)          
 set @CheckDate = DateAdd(s, 0-1, @CheckDate)          
          
 DECLARE scanbalancesheetaccounts CURSOR KEYSET FOR          
 select AccountID,AccountName from AccountsMaster where [GroupID]= @parentid --and Active=1          
 OPEN scanbalancesheetaccounts          
 FETCH FROM scanbalancesheetaccounts into @AccountID,@AccountName          
 WHILE @@FETCH_STATUS=0          
 Begin          
  If @AccountID=@CLOSINGSTOCK          
  Begin          
-- --    If @Todate<dbo.stripdatefromtime(getdate())          
   If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
   Begin          
    Select @balance=sum(opening_Value)from OpeningDetails,Items  
    where Opening_Date=dateadd(day,1,@ToDate) And OpeningDetails.Product_Code = Items.Product_Code  
   End          
   Else          
   Begin          
    --Select @balance= sum(Quantity*PurchasePrice)from Batch_Products          
    Select @balance=isnull(dbo.sp_acc_getclosingstock(),0)          
   End          
   set @balance =isnull(@balance,0)          
          
   INSERT #TempRegister          
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
   @fromdate,@todate,0,0,@LEAFACCOUNT           
  End          
  Else If @AccountID=@TAXONCLOSINGSTOCK          
  Begin     
-- --    If @Todate<dbo.stripdatefromtime(getdate())          
   If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
   Begin          
    Select @balance = Sum(Case When IsNull(Items.VAT,0) = 1 Then   
    (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then  
    (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else  
    (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then  
    (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)  
    from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code  
    And Opening_Date = DateAdd(Day,1,@ToDate)  
   End          
   Else          
   Begin          
    --Select @balance= sum((Quantity*PurchasePrice)*(isnull(TaxSuffered,0)/100))from Batch_Products          
    Select @balance=isnull(dbo.sp_acc_getTaxonClosingStock(),0)          
   End          
   set @balance =isnull(@balance,0)          
          
   INSERT #TempRegister          
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
   @fromdate,@todate,0,0,@LEAFACCOUNT           
  End          
  Else If @AccountID=@DEPRECIATION          
  Begin          
   execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@balance output          
   set @balance =isnull(@balance,0)          
          
   INSERT #TempRegister          
 select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END, 
   @fromdate,@todate,0,0,@LEAFACCOUNT           
  End          
          
  Else If @AccountID<>@OPENINGSTOCK AND @AccountID<>@TAXONOPENINGSTOCK          
--  Else          
   Begin          
    If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)          
    Begin          
     Select @LastBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID and Active=1          
    End          
    Else          
    Begin           
     set @LastBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID),0)          
    End          
    -- Depreciation value deducted from fixed Assest leaf account          
    Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output          
    If @Exists=1          
    Begin          
     Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)          
              
     --If @DepPercent>0           
     --Begin          
 --      Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
 --      from Batch_Assets where IsNull(Saleable,0)=1 and AccountID=@AccountID          
 --      set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
 --      Set @Balance=IsNull(@APVBalanceAmt,0)          
     --End          
     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
     from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID          
     set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
     Set @Balance=IsNull(@APVBalanceAmt,0)          
              
     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
     from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID          
     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
              
     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
     from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDatePair and AccountID=@AccountID          
     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
              
     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
     from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and          
     Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID          
     And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDatePair And ARVAbstract.ARVDate > @ToDatePair)          
     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0) 
     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
           
     Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)          
           
     INSERT #TempRegister          
    select 'Group ID'= @AccountID,'Group Name'= @AccountName + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@DepAmount as nvarchar(50)),          
     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
     @fromdate,@todate,0,0,@LEAFACCOUNT           
           
    End          
    Else          
    Begin          
     set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
     where [TransactionDate] between @todate and @ToDatePair and [AccountID] = @AccountID and          
     documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          
     set @balance=@balance + @LastBalance          
           
     INSERT #TempRegister          
     select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
     @fromdate,@todate,0,0,@LEAFACCOUNT           
    End          
   End          
   /*INSERT #TempRegister                  
   select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
   'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
   'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
   @fromdate,@todate,0,0,@LEAFACCOUNT           
   */          
   FETCH NEXT FROM scanbalancesheetaccounts into @AccountID,@AccountName          
  End          
  CLOSE scanbalancesheetaccounts          
  DEALLOCATE scanbalancesheetaccounts          
           
  select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister          
            
  INSERT #TempRegister          
  select '','Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL          
            
--   select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'', 'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister           
-- Drop table #TempRegister          
END          
ELSE IF @mode=@LEAFACCOUNT           
BEGIN          
   exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State  
END          
ELSE IF @mode =@NEXTLEVEL          
BEGIN          
   exec sp_acc_rpt_accountdetail @docref,@doctype,@Info           
END          
ELSE IF @Mode = @SPECIALCASE3 and @parentid=0          
BEGIN          
 exec sp_acc_rpt_tradingac @fromdate,@todate,3          
END          
ELSE IF @Mode = @SPECIALCASE4 and @parentid=0          
BEGIN          
 Set @ConvertInfo=Cast(@Info as Decimal(18,6))          
 exec sp_acc_rpt_netprofitdetail @ConvertInfo          
END 

