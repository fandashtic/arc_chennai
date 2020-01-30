CREATE Procedure sp_acc_rpt_tradingacrecursivebalance(@parentid integer,@fromdate datetime, @todate datetime,@balance decimal(18,6) output,@TotalDepAmt decimal(18,6) = 0 output)          
as          
Declare @OpenDate DateTime -- Opening date from setup          
Select @OpenDate=dbo.stripdatefromtime(OpeningDate) from setup          
          
DECLARE @ToDatePair datetime        
Set @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
        
Set @TotalDepAmt=0          
Set @balance=0          
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
 --Update #temp Set Status = 1 Where GroupID = @GroupID          
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
Set @StrDate=  dbo.sp_acc_GetFiscalYearStart()          
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
 If @AccountID=@OPENINGSTOCK          
 Begin          
  Select @AccountBalance=sum(opening_Value) from OpeningDetails,Items where Opening_Date=@FromDate And OpeningDetails.Product_Code = Items.Product_Code          
  set @AccountBalance =isnull(@AccountBalance,0)          
 End          
 Else If @AccountID=@TAXONOPENINGSTOCK          
 Begin          
  Select @AccountBalance = Sum(Case When IsNull(Items.VAT,0) = 1 Then   
  (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then  
  (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else  
  (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then  
  (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)  
  from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code  
  And Opening_Date = @FromDate  
  set @AccountBalance =isnull(@AccountBalance,0)          
 End          
 Else If @AccountID = @CLOSINGSTOCK          
 Begin          
  If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
  Begin          
   Select @AccountBalance=sum(opening_Value)from OpeningDetails,Items  
   where Opening_Date=dateadd(day,1,@ToDate) And OpeningDetails.Product_Code = Items.Product_Code  
  End          
  Else          
  Begin          
   --Select @AccountBalance= sum(Quantity*PurchasePrice)from Batch_Products          
   Select @AccountBalance= isnull(dbo.sp_acc_getClosingStock(),0)          
  End          
  set @AccountBalance =isnull(@AccountBalance,0)          
 End          
 Else If @AccountID = @TAXONCLOSINGSTOCK         
 Begin          
  If @Todate<dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))          
  Begin          
   Select @AccountBalance = Sum(Case When IsNull(Items.VAT,0) = 1 Then   
   (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then  
   (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else  
   (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then  
   (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)  
   from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code  
   And Opening_Date = DateAdd(Day,1,@ToDate)  
  End          
  Else          
  Begin          
   --Select @AccountBalance= sum((Quantity*PurchasePrice)*(isnull(TaxSuffered,0)/100)) from Batch_Products          
   Select @AccountBalance= isnull(dbo.sp_acc_getTaxonClosingStock(),0)          
  End          
  set @AccountBalance =isnull(@AccountBalance,0)          
 End          
 Else if @AccountID=@DEPRECIATION          
 Begin          
  execute sp_acc_rpt_depreciationComputation @Todate,@FIXEDASSETS,@AccountBalance output          
  set @AccountBalance =isnull(@AccountBalance,0)          
 End          
 Else if @AccountID<>@OPENINGSTOCK AND @AccountID<>@TAXONOPENINGSTOCK           
 Begin          
  Set @AccountBalance=0          
--   If Not exists(Select top 1 openingvalue from AccountOpeningBalance where  OpeningDate=@todate and AccountID =@AccountID)          
--   Begin          
--    Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID and isnull(Active,0)=1          
--   End          
--   Else          
--   Begin           
--    set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@todate and AccountID=@AccountID),0)          
--   End          
          
  Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output          
  If @Exists=1          
  Begin          
   Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)          
   --If @DepPercent>0           
   --Begin          
--     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),          
--     @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))           
--     from Batch_Assets where IsNull(Saleable,0)=1 and AccountID=@AccountID          
--               
--     set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
--     Set @AccountBalance=IsNull(@APVBalanceAmt,0)          
   --End          
   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
   from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID          
   set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
   Set @AccountBalance=IsNull(@APVBalanceAmt,0)          
            
   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
   from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID          
   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
   Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)          
            
   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
   from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDatePair and AccountID=@AccountID          
   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
   Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)          
            
   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
   from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and          
   Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID          
   And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDatePair And ARVAbstract.ARVDate > @ToDatePair)             
   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)     
   Set @AccountBalance=IsNull(@AccountBalance,0) + IsNull(@APVBalanceAmt,0)          
          
   Set @AccountBalance=IsNull(@AccountBalance,0) - IsNull(@DepAmount,0)          
   Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)          
 End          
  Else          
  Begin          
   If @OpenDate=dbo.stripdatefromtime(@FromDate)          
   Begin          
     If Not exists(Select top 1 openingvalue from AccountOpeningBalance where  OpeningDate=@FromDate and AccountID =@AccountID)          
     Begin          
      Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1          
     End          
     Else          
     Begin           
      set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@FromDate and AccountID=@AccountID),0)          
     End          
   End          
   set @Accountbalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
   where [TransactionDate] between @fromdate and @ToDatePair and [AccountID] = @AccountID and           
   documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)and isnull(status,0) <> 128 and isnull(status,0) <> 192), 0)          
   Set @AccountBalance=@AccountBalance+IsNull(@LastBalance,0)          
  End          
 End          
 set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)          
 Set @AccountBalance=0          
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

