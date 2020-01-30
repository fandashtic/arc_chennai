CREATE Procedure sp_acc_rpt_FundsFlow_Detail(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null,@State Int=0,@Hide0BalAC Int =0)
as      
/*   
Purpose : This is Drill Down procedure for Funds Flow Statement  
*/  
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
  
Declare @OpeningBalance Decimal(18,6)  
Declare @ClosingBalance Decimal(18,6)  
  
DECLARE @ToDatePair datetime          
DECLARE @FromDatePair datetime          
Declare @PassedFromDate Datetime  
  
Set @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))          
Set @FromDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @FromDate))          
      
SET @NEXTLEVEL =0          
SET @NONEXTLEVEL =1        
SET @LEAFACCOUNT =2          
SET @ACCOUNTGROUP =65  
          
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
Declare @Setupdate datetime  
select @SetupDate = dbo.stripdatefromtime(OpeningDate) from setup  
  
  
set @PassedFromDate = @fromdate          
--IF @mode = @ACCOUNTGROUP or (@Mode = @SPECIALCASE3 and @parentid>0)          
IF @mode = @ACCOUNTGROUP and @parentid > 0  
BEGIN          
 --From date is changed inside the if condition , so asign it to another variable and display in front-end  
 Set @FromDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @FromDate))          
 if @setupdate <> @fromdate  
  Begin  
   -- if fromdate is changed the fromdate pair has to be changed   
   Set @fromdate = Dateadd(dd,-1,@fromdate)  
   Set @FromDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @FromDate))          
  End  
 set @parentgroup1 = @parentid          
 create Table #TempRegister(GroupID integer,GroupName nvarchar(255),  
 Opening Decimal(18,6),Closing Decimal(18,6),TotDifference   
 Decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)          
  DECLARE scanrootlevel CURSOR KEYSET FOR          
  select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1           
  and GroupID<>54 --Opening Stock group  and Active=1   
            
  OPEN scanrootlevel          
            
  FETCH FROM scanrootlevel into @groupid,@group          
            
  WHILE @@FETCH_STATUS =0          
  BEGIN          
-- --        execute sp_acc_rpt_recursivebalance @groupid,@Setupdate,@fromdate,@balance output,@TotalDepAmt output          
  if @setupdate = @Passedfromdate  
   Begin  
         execute sp_acc_rpt_FundsFlow_Recursivebalance @groupid,@Setupdate,@Setupdate,@balance output,@TotalDepAmt output ,1  
   End  
  Else  
   Begin  
    execute sp_acc_rpt_FundsFlow_Recursivebalance @groupid,@Setupdate,@fromdate,@balance output,@TotalDepAmt output ,0  
   End  
       If @TotalDepAmt=0          
     Begin   
    -- Depreciation shud not be taken  
    If @Groupid = 45   
     Begin  
      set @Balance = 0  
     End  
          INSERT INTO #TempRegister  
          SELECT 'Group ID'= @groupid,'Group Name'=@group,  
	    'Opening Balance'= @balance,  
	    Null,0,@Setupdate,@FromDate,0,0,@ACCOUNTGROUP  
	    Set @OpeningBalance = @balance  
     End           
      Else          
     Begin          
          INSERT INTO #TempRegister          
          SELECT 'Group ID'= @groupid,'Group Name'=@group ,  
    'Opening Balance'= @balance + @TotalDepAmt,  
    Null,0,@Setupdate,@fromdate,0,0,@ACCOUNTGROUP               
    Set @OpeningBalance = @balance + @TotalDepAmt  
     End   
  
       execute sp_acc_rpt_FundsFlow_Recursivebalance @groupid,@Setupdate,@Todate,@balance output,@TotalDepAmt output , 0  
-- --        execute sp_acc_rpt_recursivebalance @groupid,@Setupdate,@Todate,@balance output,@TotalDepAmt output  
       If @TotalDepAmt=0          
     Begin     
    -- if depreciation then balance = 0 as Funds flow doesnt include depreciation  
    If @Groupid = 45   
     Begin  
      set @Balance = 0  
     End  
    Set @ClosingBalance = @Balance  
    Update #TempRegister set   
    Closing = @balance,  
    TotDifference = @ClosingBalance - @OpeningBalance  
    Where Groupid = @Groupid  
     End           
      Else          
     Begin          
    Set @ClosingBalance = @balance + @TotalDepAmt  
    Update #TempRegister set   
    Closing = @balance + @TotalDepAmt,  
    TotDifference = @ClosingBalance - @OpeningBalance  
    Where Groupid = @Groupid  
     End   
   
     FETCH NEXT FROM scanrootlevel into @groupid,@group          
  END          
  CLOSE scanrootlevel          
  DEALLOCATE scanrootlevel          
           
  Declare @AccountID Int,@AccountName nvarchar(50)          
  Declare @DepPercent Decimal(18,6), @DepAmount Decimal(18,6), @Exists Int          
           
  Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)          
  Declare @CheckDate as datetime,@StrDate as nvarchar(255), @APVBalanceAmt as Decimal(18,6)          
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
-- --        If @Fromdate<dbo.stripdatefromtime(getdate())          
       If @Fromdate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
        Begin          
         Select @balance=sum(opening_Value)from OpeningDetails,Items  
         where Opening_Date=dateadd(day,1,@Fromdate) And OpeningDetails.Product_Code = Items.Product_Code  
        End          
       Else          
        Begin          
         Select @balance=isnull(dbo.sp_acc_getclosingstock(),0)          
        End          
        set @OpeningBalance =isnull(@balance,0)          
  
      INSERT #TempRegister          
      select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
      'Opening'=@OpeningBalance,0,0,  
    @Passedfromdate,@todate,0,0,@LEAFACCOUNT           
-- --        If @Todate<dbo.stripdatefromtime(getdate())          
       If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
        Begin          
         Select @balance=sum(opening_Value)from OpeningDetails,Items  
         where Opening_Date=dateadd(day,1,@ToDate) And OpeningDetails.Product_Code = Items.Product_Code  
        End          
       Else          
        Begin          
         Select @balance=isnull(dbo.sp_acc_getclosingstock(),0)          
        End          
        set @Closingbalance =isnull(@balance,0)          
  
    Update #TempRegister set   
    Closing = @Closingbalance,  
    TotDifference = @ClosingBalance - @OpeningBalance  
    Where Groupid = @AccountID  
     End          
  Else If @AccountID=@TAXONCLOSINGSTOCK          
     Begin          
-- --        If @Fromdate<dbo.stripdatefromtime(getdate())          
       If @Fromdate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
        Begin          
         Select @balance = Sum(Case When IsNull(Items.VAT,0) = 1 Then   
         (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then  
         (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else  
         (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then  
         (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)  
         from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code  
         And Opening_Date = DateAdd(Day,1,@Fromdate)  
        End          
       Else          
        Begin        
         Select @balance=isnull(dbo.sp_acc_getTaxonClosingStock(),0)          
        End          
       set @Openingbalance =isnull(@balance,0)          
  
      INSERT #TempRegister          
      select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
      'Opening'= @Openingbalance,0,0,  
      @Passedfromdate,@todate,0,0,@LEAFACCOUNT           

-- --        If @Todate<dbo.stripdatefromtime(getdate())          
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
         Select @balance=isnull(dbo.sp_acc_getTaxonClosingStock(),0)          
        End          
    set @Closingbalance =isnull(@balance,0)          
    Update #TempRegister set   
    Closing = @Closingbalance,  
    TotDifference = @ClosingBalance - @OpeningBalance  
    Where Groupid = @AccountID  
  
     End          
    Else If @AccountID=@DEPRECIATION          
     Begin        
    /* for funds flow statement Depreciations shud not be considered , since it  
     is a non cash item.  
    */  
       set @balance = 0  
    INSERT #TempRegister          
       select 'Group ID'= @AccountID,'Group Name'= @AccountName,  
       'Opening'=0,'Closing' = 0, 0,  
       @Passedfromdate,@todate,0,0,@LEAFACCOUNT  
-- -- --   execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@balance output          
     End          
    Else If @AccountID<>@OPENINGSTOCK AND @AccountID<>@TAXONOPENINGSTOCK     
  Begin          
       Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output          
       If @Exists=1          
       Begin          
        Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0) --and isnull(Active,0)=1),0)          
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
        from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID          
        set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
        Set @Balance=IsNull(@APVBalanceAmt,0)          
   
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
        from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @FromDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID          
        set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
        Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
   
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
        from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @Fromdatepair and AccountID=@AccountID          
        set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
        Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
   
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
        from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and          
        Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID          
        And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @FromDAtePair And ARVAbstract.ARVDate > @FromDatePair)          
        set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
        Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
     -- dereciation shud not be deducted from the Asset  
        Set @balance=IsNull(@balance,0) -- - IsNull(@DepAmount,0)          
           Set @OpeningBalance = @Balance  
  
        INSERT #TempRegister          
        select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
        'Opening'= @balance,          
     Null,Null,  
        @SetUpdate,@fromdate,0,0,@LEAFACCOUNT           
   
     --get the closing balance  
        Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)        -- and isnull(Active,0)=1),0)          
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
  
     -- Depreciation shud not be deducted  
        Set @balance=IsNull(@balance,0) --- IsNull(@DepAmount,0)          
           Set @ClosingBalance = @Balance  
  
     Update #TempRegister set   
     Closing = @balance,  
     TotDifference = @ClosingBalance - @OpeningBalance  
     Where Groupid = @AccountID  
       End          
       Else          
       Begin          
     if @Setupdate <> @Passedfromdate  
      -- if set update is passed as from date then only opening balance has to be taken  
      Begin  
          If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate= dateadd(dd,1,@FromDate) and AccountID =@AccountID)  
           Begin      
            Select @OpeningBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID --and Active=1          
           End          
          Else          
           Begin     
         -- since From date is deducted for calculating Fixed asset total , Fromdate is added to find the opening balance  
            set @OpeningBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate= dateadd(dd,1,@FromDate) and AccountID =@AccountID),0)          
           End          
      End  
     Else  
      Begin  
          If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate= @FromDate and AccountID =@AccountID)          
           Begin      
            Select @OpeningBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID --and Active=1          
           End          
          Else          
           Begin     
            set @OpeningBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate= @FromDate and AccountID =@AccountID),0)          
           End          
      End  
  
        If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)          
         Begin          
          Select @ClosingBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID --and Active=1          
         End          
        Else          
         Begin           
          set @ClosingBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID),0)          
         End          
      set @balance = @Openingbalance  
 
        INSERT #TempRegister          
        select 'Group ID'= @AccountID,'Group Name'= @AccountName,          
        'Opening'= @balance,          
     Null,Null,  
        @SetUpdate,@fromdate,0,0,@LEAFACCOUNT           
  
     Set @Balance = 0  
        set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
        where [TransactionDate] between @todate and @ToDatePair and [AccountID] = @AccountID and          
        documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          
        set @balance=@balance + @ClosingBalance  
     set @ClosingBalance = @Balance  
  
     Update #TempRegister set   
     Closing = @balance,  
     TotDifference = @ClosingBalance - @OpeningBalance  
     Where Groupid = @AccountID  
       End          
     End          
    FETCH NEXT FROM scanbalancesheetaccounts into @AccountID,@AccountName          
  End          
 CLOSE scanbalancesheetaccounts          
 DEALLOCATE scanbalancesheetaccounts          
   
 Declare @TotalAmount Decimal(18,6)  
  
 select @totaldebit = SUM(ISNULL(Opening,0)),@totalcredit = SUM(ISNULL(Closing,0)),   
 @TotalAmount = sum(Isnull(totDifference,0))  
 from #TempRegister  
  
          
 INSERT #TempRegister          
 select '',dbo.lookupdictionaryitem('Total',Default),@totaldebit,@totalcredit,@TotalAmount,@fromdate,@todate,0,0,@NONEXTLEVEL          

 If @Hide0BalAC = 0
 Begin
	select 'Account/Group'= GroupName,  
	'Opening Balance'=  
	Case  
	  	When opening < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
	End,  
	'Closing Balance'=  
	Case  
	  	When Closing < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(Closing) as nvarchar(50))))  
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(Closing) as nvarchar(50)) ))  
	End,  
	'Difference' =  
	Case  
	  	When TotDifference < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(TotDifference) as nvarchar(50))))  
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(TotDifference) as nvarchar(50)) ))  
	End,
	'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,
	@PassedFromDate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister
 End
 Else
 Begin
	select 'Account/Group'= GroupName,  
	'Opening Balance'=  
	Case  
	 	When opening < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
	End,  
	'Closing Balance'=  
	Case  
	  	When Closing < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(Closing) as nvarchar(50))))  
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(Closing) as nvarchar(50)) ))  
	End,  
	'Difference' =  
	Case  
	  	When TotDifference < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(TotDifference) as nvarchar(50))))  
	  	else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(TotDifference) as nvarchar(50)) ))  
	End,
	'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,
	@PassedFromDate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister
	Where ((Isnull(opening,0) <> 0 or Isnull(Closing,0) <> 0) or isnull(colorinfo,0) in (1,65))
 End 
 Drop table #TempRegister          
END          
ELSE IF @mode=@LEAFACCOUNT           
BEGIN        
   exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State          
END          
ELSE IF @mode =@NEXTLEVEL          
BEGIN          
-- -- --  if @setupdate = @Todate  
-- -- --   Begin  
-- -- --    Set @Todate = Dateadd(dd,-1,@Todate)  
-- -- --   End  
   exec sp_acc_rpt_accountdetail @docref,@doctype,@Info           
END          
ELSE IF @Mode = 6 and @Parentid=-1  
BEGIN          
-- --  if @setupdate <> @FromDate  
-- --   Begin  
-- --    Set @fromdate = Dateadd(dd,-1,@fromdate)  
-- --   End  
-- Pass 0 to find out the Closing Trading A/C  
 exec sp_acc_rpt_tradingac_fundsflow @fromdate,@todate,0,@PassedFromDate,@Hide0BalAC
END  
ELSE IF @Mode = @SPECIALCASE4 and @parentid=0          
BEGIN  
  Set @ConvertInfo=Cast(@Info as Decimal(18,6))          
  exec sp_acc_rpt_netprofitdetail @ConvertInfo          
END  
ELSE IF @Mode = 66 and @parentid=-2  
BEGIN  
 --this block is executed when the Inc/Dec in working capital is double clicked  
 create Table #WorkingCapital(GroupID integer,GroupName nvarchar(255),  
 Opening Decimal(18,6),Closing Decimal(18,6),TotDifference   
 Decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,  
 DocType integer,ColorInfo integer)          
  
 Declare @CLOpeningBal Decimal(18,6), @CLClosingBal Decimal(18,6)  
 Declare @CAOpeningBal Decimal(18,6), @CAClosingBal Decimal(18,6)  
 Declare @CADifference Decimal(18,6), @CLDifference Decimal(18,6)  
 Set @CLOpeningBal = 0  
 Set @CLClosingBal = 0  
 Set @CAOpeningBal = 0  
 Set @CAClosingBal = 0  
 Set @CADifference = 0  
 Set @CLDifference = 0  
  
 set @PassedFromDate = @fromdate 
 if @setupdate <> @fromdate  
  Begin  
   Set @fromdate = Dateadd(dd,-1,@fromdate)  
  End  
 -- Get the Current Asset Opening and Closing Balance  
  
-- --  execute sp_acc_rpt_recursivebalance 17,@Setupdate,@FromDate,@balance output,@TotalDepAmt output   
 if @setupdate = @PassedFromDate  
  Begin  
   execute sp_acc_rpt_FundsFlow_Recursivebalance 17,@Setupdate,@Setupdate,@balance output,@TotalDepAmt output,1  
   Set @CAOpeningBal = @Balance  
  End  
 Else  
  Begin  
   execute sp_acc_rpt_FundsFlow_Recursivebalance 17,@Setupdate,@FromDate,@balance output,@TotalDepAmt output,0  
   Set @CAOpeningBal = @Balance  
  End  
  
 execute sp_acc_rpt_FundsFlow_Recursivebalance 17,@Setupdate,@ToDate,@balance output,@TotalDepAmt output,0  
 Set @CAClosingBal = @Balance  
  
 set @CADifference = @CAClosingBal - @CAOpeningBal  
  
 Insert into #WorkingCapital (Groupid,GroupName,Opening,Closing,TotDifference,Colorinfo)  
 Values(17,dbo.LookupDictionaryItem('Current Assets',Default),@CAOpeningBal,@CAClosingBal,@CADifference,@Accountgroup)  
  
 -- Get the Current Liability Opening and Closing Balance  
 If @setupdate = @PassedFromDate  
  Begin  
   execute sp_acc_rpt_FundsFlow_Recursivebalance 8,@Setupdate,@Setupdate,@balance output,@TotalDepAmt output,1  
   Set @CLOpeningBal = @Balance  
  End  
 Else  
  Begin  
   execute sp_acc_rpt_FundsFlow_Recursivebalance 8,@Setupdate,@FromDate,@balance output,@TotalDepAmt output,0  
   Set @CLOpeningBal = @Balance  
  End  
  
 execute sp_acc_rpt_FundsFlow_Recursivebalance 8,@Setupdate,@ToDate,@balance output,@TotalDepAmt output,0  
 Set @CLClosingBal = @Balance  
  
 set @CLDifference = @CLClosingBal - @CLOpeningBal  
  
 Insert into #WorkingCapital(Groupid,GroupName,Opening,Closing,TotDifference,Colorinfo)  
 Values(8,dbo.LookupDictionaryItem('Current Liabilities',Default),@CLOpeningBal,@CLClosingBal,@CLDifference,@Accountgroup)  
  
 Insert into #WorkingCapital (Groupid,GroupName,Opening,Closing,TotDifference,Colorinfo)  
 Values(0,dbo.lookupdictionaryitem('Total',Default),@CAOpeningBal+@CLOpeningBal,@CAClosingBal+@CLClosingBal,@CADifference + @CLDifference,1)  
  
 select 'Account/Group'= GroupName,  
 'Opening Balance'=  
 Case  
  When opening < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
  else dbo.LookupDictionaryItem('Dr ',Default) + Cast(Abs(Opening) as nvarchar(50))   
 End,  
 'Closing Balance'=  
 Case  
  When Closing < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(Closing) as nvarchar(50))))  
  else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(Closing) as nvarchar(50)) ))  
 End,  
 'Difference' =  
 Case  
  When TotDifference < 0 then dbo.LookupDictionaryItem('Cr ',Default) + Ltrim(rtrim(Cast(Abs(TotDifference) as nvarchar(50))))  
  else dbo.LookupDictionaryItem('Dr ',Default) + Ltrim(Rtrim(Cast(Abs(TotDifference) as nvarchar(50)) ))  
 End,  
 'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,  
 @PassedFromDate,@todate,0,0,ColorInfo,ColorInfo from #WorkingCapital           
   
 Drop Table #WorkingCapital  
END 


