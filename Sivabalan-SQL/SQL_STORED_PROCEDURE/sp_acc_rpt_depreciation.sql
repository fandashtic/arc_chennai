CREATE procedure sp_acc_rpt_depreciation(@FromDate DateTime,@ToDate DateTime)        
As        
        
Declare @GroupID int,@AccountID Int,@AccountName nvarchar(50),@TransactionID int        
Declare @DepPercent as decimal(18,6),@DepAmount as decimal(18,6)        
Declare @OpeningBalance decimal(18,6)        
Declare @Additions decimal(18,6)        
Declare @Sales decimal(18,6)        
Declare @ClosingBalanceBeforeDepriciation decimal(18,6)        
Declare @ClosingBalanceAfterDepriciation decimal(18,6)        
Declare @TranID Int        
Declare @Debit Int        
Declare @Credit Int        
      
Declare @ToDatePair datetime      
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
        
DECLARE @FIXEDASSETGROUP INT,@DEPRECIATION INT        
SET @FIXEDASSETGROUP=13        
SET @DEPRECIATION=24        
Create Table #TempDepreciation(Asset nvarchar(50),OpeningBalance decimal(18,6),Addition decimal(18,6),        
Sales decimal(18,6),ClosingBalance1 decimal(18,6),DepRate decimal(18,6),DepAmount decimal(18,6),ClosingBalance2 decimal(18,6),AssetId Int,HighLight Integer)        
Create Table #temp(GroupID int)        
Insert into #temp select GroupID From AccountGroup Where ParentGroup = @FIXEDASSETGROUP --and isnull(Active,0)=1        
Declare Parent Cursor Dynamic For        
Select GroupID From #temp        
Open Parent        
Fetch From Parent Into @GroupID        
While @@Fetch_Status = 0        
Begin        
 Insert into #temp         
 Select GroupID From AccountGroup Where ParentGroup = @GroupID --and isnull(Active,0)=1        
 Fetch Next From Parent Into @GroupID        
End        
Close Parent        
DeAllocate Parent        
        
Insert into #temp values(@FIXEDASSETGROUP)        
        
Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)        
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@APVBalanceAmt Decimal(18,6),@StartDate DateTime,@EndDate DateTime        
Declare @YearStart Int,@FiscalYear Int,@OpeningDate DateTime        
Select @FiscalYear=IsNull(FiscalYear,4),@OpeningDate=OpeningDate From Setup        
If @FiscalYear =1        
Begin        
 Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast(Year(@OpeningDate) As nVarchar(50))-- From Setup        
End        
Else        
Begin        
 If Month(@OpeningDate) < @Fiscalyear        
 Begin        
  Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast((Year(@OpeningDate)-1) As nVarchar(50))        
 End        
 Else        
 Begin        
  Select @StrDate=  N'1/' + Cast(IsNull(@FiscalYear,4) as nvarchar) + N'/' + Cast(Year(@OpeningDate) As nVarchar(50))-- From Setup        
 End        
End        
--Set @StrDate=@YearStartDate        
Set @CheckDate =Cast(@StrDate As DateTime)        
set @CheckDate = DateAdd(m, 6, @CheckDate)        
set @CheckDate = DateAdd(s, 0-1, @CheckDate)        
        
Set @StartDate=Cast(@StrDate As DateTime)        
Set @EndDate=Cast(@StrDate As DateTime)        
set @EndDate = DateAdd(m, 12, @EndDate)        
set @EndDate = DateAdd(d, 0-1, @EndDate)        
        
Declare TotalAccount Cursor Keyset For        
Select AccountID,AccountName From AccountsMaster where GroupID in (Select * from #Temp) --and isnull(Active,0)=1        
Open TotalAccount        
Fetch From TotalAccount Into @AccountID,@AccountName        
While @@Fetch_Status = 0        
Begin        
/* Set @Additions=0        
 Set @Sales=0        
 Set @ClosingBalanceBeforeDepriciation=0        
 Set @ClosingBalanceAfterDepriciation=0        
 Select  @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId =@AccountID and isnull(Active,0)=1        
 Declare scanGJDep Cursor Keyset for        
 Select TransactionID,Debit,Credit from GeneralJournal where AccountID=@AccountID   
 and isnull(status,0) <> 128 and isnull(status,0) <> 192        
 Open ScanGJDep        
 Fetch from scangjdep into @TranID,@Debit,@Credit        
 While @@Fetch_Status=0   
 Begin        
  If not exists(Select AccountID from GeneralJournal where TransactionID=@TranID and AccountID=@DEPRECIATION)        
  Begin        
   Set @Additions=isnull(@Additions,0)+isnull(@Debit,0)        
   Set @Sales=isnull(@Sales,0) + isnull(@Credit,0)        
  End        
  Fetch Next from scangjdep into @TranID,@Debit,@Credit        
 End        
 Close scangjdep        
 Deallocate scangjdep        
 --select @Additions=sum(isnull(debit,0)),@Sales=sum(isnull(Credit,0)) from generaljournal where AccountID = @AccountID        
 Set @ClosingBalanceBeforeDepriciation=(@OpeningBalance+@Additions)-@Sales        
 Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)        
 If @DepPercent>0         
 Begin        
  Set @DepAmount=@ClosingBalanceBeforeDepriciation * (@DepPercent/100)        
  If @DepAmount > 0        
  Begin        
   Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation-@DepAmount        
  End        
 End        
 Insert Into #TempDepreciation values(@AccountName,@OpeningBalance,@Additions,@Sales,        
     @ClosingBalanceBeforeDepriciation,@DepPercent,        
     @DepAmount,@ClosingBalanceAfterDepriciation,@AccountID,2) --2 ->High Light(ledger level)        
*/        
 Select @OpeningBalance = Sum(IsNull(OPWDV,0)) from Batch_Assets where AccountID=@AccountID and         
 ((IsNull(APVID,0)=0 and CreationTime < @StartDate and IsNull(Saleable,0)=1) Or        
 (IsNull(APVID,0)=0 and CreationTime >= @StartDate) Or        
 (IsNull(APVID,0)<>0 and APVDate < @StartDate and IsNull(Saleable,0)=1 ) Or        
 (isnull(ARVID,0)<>0 and IsNull(Saleable,0)=0 and CreationTime < @StartDate And (select ARVDate from ARVAbstract where ARVAbstract.Documentid=Batch_Assets.ARVID) Between @StartDate and @ToDatePair))        
-- IsNull(Saleable,0) in (0,1) and AccountID=@AccountID and (IsNull(APVID,0)=0 or (dbo.stripdatefromtime(BillDate) Not Between @StartDate and @ToDate))        
        
 Select @Additions = Sum(IsNull(OPWDV,0)) from Batch_Assets where IsNull(Saleable,0) in (0,1) and AccountID=@AccountID and (IsNull(APVID,0)<> 0 and APVDate Between @StartDate and @ToDatePair)          
 Select @Sales = Sum(IsNull(OPWDV,0)) from Batch_Assets where IsNull(Saleable,0)=0 and AccountID=@AccountID and ((Select ARVDate from ARVAbstract where ARVAbstract.DocumentID = Batch_Assets.ARVID) between @StartDate and @ToDatePair)         
 Set @ClosingBalanceBeforeDepriciation=IsNull(@OpeningBalance,0)+IsNull(@Additions,0)-IsNull(@Sales,0)        
 Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)        
 If @DepPercent > 0         
 Begin        
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) from Batch_Assets         
  where IsNull(Saleable,0)=1 and AccountID=@AccountID and (APVDate Is Not Null  and (APVDate <= @ToDatePair))        
  Set @DepAmount=IsNull(@DepAPVBalanceAmt,0)        
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)) from Batch_Assets         
  where IsNull(Saleable,0)=1 and AccountID=@AccountID and APVDate Is Null        
  Set @DepAmount= IsNull(@DepAmount,0)+IsNull(@DepAPVBalanceAmt,0)        
--  Set @DepAmount=IsNull(@DepAPVBalanceAmt,0)        
  Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation-@DepAmount        
 End        
 Else        
 Begin        
  Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation        
 End        
 Insert Into #TempDepreciation values(@AccountName,IsNull(@OpeningBalance,0),IsNull(@Additions,0),IsNull(@Sales,0),        
     IsNull(@ClosingBalanceBeforeDepriciation,0),IsNull(@DepPercent,0),        
     IsNull(@DepAmount,0),IsNull(@ClosingBalanceAfterDepriciation,0),@AccountID,2) --2 ->High Light(ledger level)        
  Set @DepAmount = 0         
 Fetch Next From TotalAccount Into @AccountID,@AccountName        
End        
CLOSE TotalAccount        
DEALLOCATE TotalAccount         
Insert #TempDepreciation        
Select 'Total',Sum(OpeningBalance),sum(Addition),sum(Sales),sum(ClosingBalance1),Null,        
 sum(DepAmount),sum(ClosingBalance2),0,1 from #TempDepreciation  --1 ->High Light(no sub level with color)        
        
Select "Name of Asset"=Asset,"Opening Balance"=OpeningBalance,"Purchases"=Addition,        
 "Sales"=Sales,AssetID,@Fromdate,@Todate,0,0,2,2,"Balance"=ClosingBalance1,        
 "Dep Amount"=DepAmount,"Closing Balance"=ClosingBalance2,HighLight from #TempDepreciation        
drop table #temp        
drop table #TempDepreciation 
