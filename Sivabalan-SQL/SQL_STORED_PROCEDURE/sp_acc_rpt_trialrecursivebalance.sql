CREATE Procedure sp_acc_rpt_trialrecursivebalance(@parentid integer,@fromdate datetime, @todate datetime,@balance decimal(18,6) output,@TotalDepAmt decimal(18,6) = 0 Output,@TBType nvarchar(50) = null)                    
as            
DECLARE @STOCKINTRADE int                    
SET @STOCKINTRADE =21                    
Set @balance=0                    
Set @TotalDepAmt=0                
                  
DECLARE @ToDatePair datetime                  
declare @temp decimal(18,6)    
set @temp = 0    
    
if isnumeric(@TBType) = 0        
begin        
 set @TBType = 0        
end        
        
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))                  
                  
Create Table #temp(GroupID int,                    
     Status int)                    
Declare @GroupID int                    
--Insert into #temp select GroupID, 0 From AccountGroup                    
--Where ParentGroup = @parentid and GroupID <> @STOCKINTRADE                    
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
 --Update #temp Set Status = 1 Where GroupID = @GroupID                    
 Fetch Next From Parent Into @GroupID                    
End                    
Close Parent                    
DeAllocate Parent                    
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
--Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as nvarchar) + '/' + Cast(Year(OpeningDate) As nvarchar(50)) From Setup                    
Set @StrDate= dbo.sp_acc_getfiscalyearstart()                    
Set @CheckDate =Cast(@StrDate As DateTime)                    
set @CheckDate = DateAdd(m, 6, @CheckDate)                    
set @CheckDate = DateAdd(s, 0-1, @CheckDate)                    
              
insert into #temp values(@parentid,0)                    
Declare scanrecursiveaccounts Cursor Keyset For                    
Select AccountID from AccountsMaster where GroupID in (select groupid from #temp) and                     
AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500) --and isnull(Active,0)=1                    
Open scanrecursiveaccounts                    
Fetch From scanrecursiveaccounts Into @AccountID                    
While @@Fetch_Status=0                    
Begin         
-- -- -- SET @TEMP = 0     
 If @AccountID=@DEPRECIATION          
 Begin 
if @TBType = 1    
  Begin    
   execute sp_acc_rpt_depreciationComputation_TB @fromdate,@toDate,@FIXEDASSETS,@AccountBalance output    
  End   
  Else if @TBType = 2     
  Begin    
  /* even if the Todate is Opening Date , less 1 day and get the Dep Calculated ,     
   Coz outside the Condition the Depamt is made 0 if Fromdate and Todate are same    
  */    
   Declare @Tempdate datetime    
   Set @Tempdate = dateadd(dd,0-1,@ToDate)    
   execute sp_acc_rpt_depreciationComputation @Tempdate,@FIXEDASSETS,@AccountBalance output               
  End    
  Else    
  Begin    
      execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@AccountBalance output               
  End    
    set @AccountBalance =isnull(@AccountBalance,0)                    
   /* if from date and to date are same Depreciations shud not be calculated,     
  coz the carried fwd amt will have the dep value deducted     
   */    
  if @fromdate = @todate and @TBType = 2    
  Begin    
   set @Accountbalance = 0    
  End      
 End                    
 Else If @AccountID=@OPENINGSTOCK                    
 Begin                    
  set @AccountBalance = 0    
  if @TBType <> 1    
  Begin    
    Select @AccountBalance=sum(isnull(Opening_Value,0)) from OpeningDetails,Items where Opening_Date=@FromDate And OpeningDetails.Product_Code = Items.Product_Code  
    set @AccountBalance =isnull(@AccountBalance,0)                    
  End    
 End                    
 Else If  @AccountID=@TAXONOPENINGSTOCK                    
 Begin         
  set @AccountBalance = 0    
  If @TBType <> 1     
  Begin               
    Select @AccountBalance = Sum(Case When IsNull(Items.VAT,0) = 1 Then     
    (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then    
    (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else    
    (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then    
    (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)    
    from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code    
    And Opening_Date = @FromDate    
    Set @AccountBalance =isnull(@AccountBalance,0)                    
  End                      
 End                    
 Else                     
 Begin                    
    Set @AccountBalance=0                    
    If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)                    
  Begin                    
   Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1                    
  End                    
    Else                    
  Begin                     
   set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@todate and AccountID=@AccountID),0)                    
    End                    
  Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output        
  If @Exists=1                    
  Begin                    
  -- Active Check shud not be there for any reports    
 Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0) --and isnull(Active,0)=1),0)                    
 if @TBType = 0     
 Begin    
      set @lastbalance = 0    
      /* If an entry is put in asset register with/without opening balance */    
      Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
      from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID                    
      set @DepAmount=IsNull(@DepAPVBalanceAmt,0)                    
      Set @AccountBalance=IsNull(@APVBalanceAmt,0)                    

      /* If an asset is sold */    
      Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
      from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID                    
      set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
      Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)         
    
      /* If an entry is put in asset register with/without opening balance */      
      Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
      from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDatePair and AccountID=@AccountID                    
      set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)     
      Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
    
      /*     
    From date = 01/04/2004    
    To date = 10/02/2005    
    Sale if asset = 16/02/2004    
    when checking TB on a previous date , the asset which is sold on a future date    
    has to be taken for depreciation calculation    
      */    
      Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
      from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and                    
      Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID                    
      And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDatePair And ARVAbstract.ARVDate > @ToDatePair)                    
      set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
      Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
       
      Set @AccountBalance=IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)                    
      Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)                    
 End    
 else if @TBType = 1    
 Begin    
     set @DepAmount = 0    
     Set @Balance = 0    
    
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))              
        from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and     
        APVAbstract.APVDate between @fromdate and @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID              
        and isnull(Batch_assets.apvid,0) <> 0    
    
        set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)              
        Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)              
       
        Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))              
        from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and              
        Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID              
        And (((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) between @fromdate and @ToDatePair ) And ARVAbstract.ARVDate > @ToDatePair)              
        set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)              
        Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)              
    
-- -- --     if @fromdate = @todate    
-- -- --     begin    
-- -- --      set @depamount = 0    
-- -- --     end      
      /*    
    If an Asset having a opening balance is sold , then takin from batch assets    
    will not retreive any value ,but the Party will be Cr/Dr with the ARV/APV     
    value and TB will not tally.So take it from General journal and reduce the     
    Dep amount calculated above from the balance    
      */    
      Set @AccountBalance = 0    
      set @AccountBalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal               
      Where [TransactionDate] between @Fromdate and @ToDatePair and [AccountID] = @AccountID and             
      documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)              
    
      Set @AccountBalance=IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)             
      Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)          
 End    
 else if @TBType = 2     
 Begin    
   if @fromdate <> @todate    
   Begin    
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1     
       and AccountID=@AccountID -- and creationtime < @todate    
    
       set @DepAmount=IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@APVBalanceAmt,0)                    
    
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID     
       and APVAbstract.APVDate < @ToDate and IsNull(Saleable,0)=1 and     
       AccountID=@AccountID -- and Batch_Assets.creationtime < @todate    
    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
    
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And     
       IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and     
       ARVAbstract.ARVDate > @ToDate and AccountID=@AccountID    
       -- and Batch_Assets.creationtime < @todate    
    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
    
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and                    
       Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID                    
       And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) < @ToDate    
       And ARVAbstract.ARVDate > @ToDate)                    
       -- and Batch_Assets.creationtime < @todate    
    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
   End    
   else if @fromdate = @todate    
   Begin    
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID                    
       set @DepAmount=IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@APVBalanceAmt,0)                 
                          
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and     
       APVAbstract.APVDate < @ToDate and IsNull(Saleable,0)=1 and AccountID=@AccountID                    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
                          
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID     
       and ARVAbstract.ARVDate > @ToDate and AccountID=@AccountID                    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
     
       Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                    
       from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and                    
       Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID                    
       And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) < @ToDate And     
       ARVAbstract.ARVDate > @ToDate)                    
       set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                    
       Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)                    
   End    
          
     /* if from date and to date are same Depreciations shud not be calculated,     
    coz the carried fwd amt will have the dep value deducted     
     */    
       
      If @fromdate = @todate     
      Begin    
       set @DepAmount = 0     
      End    
      Set @AccountBalance=IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)    
      Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)                    
      set @lastbalance = @accountbalance    
  End    
  End                    
  Else                    
  Begin                    
 SET @TEMP = 0     
 IF @TBType = 1    
 begin    
    set @Accountbalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal                   
    Where [TransactionDate] between @fromdate and @ToDatePair    
    and [AccountID] = @AccountID and documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192), 0)                  
    End                                    
 else    
 begin    
    set @Accountbalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal                   
    Where [TransactionDate] between @todate and @ToDatePair    
    and [AccountID] = @AccountID and documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192), 0)                  
    End                                    
  end    
  if isnull(@TBType,0) = 0         
  begin        
  Set @AccountBalance=isnull(@AccountBalance,0)+@LastBalance                    
  end        
  else if @TBType = 1        
  Begin        
--  set @temp = @temp + isnull(@LastBalance,0)    
     set @temp = @temp + @Accountbalance    
     set @accountbalance = @temp    
     set @LastBalance = 0     
  End        
  else if @TBType = 2        
  Begin        
  set @AccountBalance = @lastbalance        
  End        
        
--   Set @AccountBalance=isnull(@AccountBalance,0)+@LastBalance                    
 End                    
 set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)                    
 Fetch Next From scanrecursiveaccounts Into @AccountID                    
End                    
Set @balance=isnull(@balance,0)                    
Set @TotalDepAmt=isnull(@TotDepAmt,0)                    
Close scanrecursiveaccounts                    
DeAllocate scanrecursiveaccounts                    
                    
/*set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal                     
where dbo.stripdatefromtime([TransactionDate]) between @fromdate and @todate and               
([AccountID] in (select [AccountID] from [AccountsMaster] where [GroupID] in (select groupid from #temp)))), 0)                    
set @balance=@Balance + @LastBalance                 
*/                    
    
drop table #temp 
