CREATE procedure sp_acc_rpt_depreciationComputation(@ToDate datetime,@FixedAssetGroup Int,@DepreciationValue Decimal(18,6) Output)    
As    
Declare @GroupID Int,@AccountID Int,@Balance Decimal(18,6),@TransactionID Int    
Declare @DepPercent as decimal(18,6),@DepAmount as decimal(18,6),@TotalDepAmt Decimal(18,6)    
--DECLARE @FIXEDASSETGROUP INT    
DECLARE @DEPRECIATIONACCOUNT INT    
DECLARE @YEARENDTYPE INT    
    
--SET @FIXEDASSETGROUP=13    
SET @DEPRECIATIONACCOUNT=24    
SET @YEARENDTYPE=27    
--To Optimize Report Speed  
DECLARE @ToDatePair datetime        
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
  
Declare @TranID1 Int, @Debit1 Decimal(18,6), @Credit1 Decimal(18,6), @TotalDebit1 Decimal(18,6), @TotalCredit1 Decimal(18,6)    
Create Table #tempdepcomp(GroupID int)    
Insert into #tempdepcomp select GroupID From AccountGroup Where ParentGroup = @FixedAssetGroup --and isnull(Active,0)=1    
Declare Parent Cursor Dynamic For    
Select GroupID From #tempdepcomp    
Open Parent    
Fetch From Parent Into @GroupID    
While @@Fetch_Status = 0    
Begin    
 Insert into #tempdepcomp     
 Select GroupID From AccountGroup Where ParentGroup = @GroupID --and isnull(Active,0)=1    
 Fetch Next From Parent Into @GroupID    
End    
Close Parent    
DeAllocate Parent    
    
insert into #tempdepcomp values(@FixedAssetGroup)    
    
Declare @OpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)    
Declare @CheckDate as datetime,@StrDate as nvarchar(255)    
--Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup    
Set @StrDate=  dbo.sp_acc_GetFiscalYearStart()    
Set @CheckDate =Cast(@StrDate As DateTime)    
set @CheckDate = DateAdd(m, 6, @CheckDate)    
set @CheckDate = DateAdd(s, 0-1, @CheckDate)    
    
Declare TotalAccount Cursor Keyset For    
Select AccountID From AccountsMaster where GroupID in (Select * from #Tempdepcomp) --and isnull(Active,0)=1    
Open TotalAccount    
Fetch From TotalAccount Into @AccountID    
While @@Fetch_Status = 0    
Begin    
 Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)    
 If @DepPercent>0     
 Begin    
  Set @DepAmount=0    
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))     
  from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID     
  set @DepAmount=IsNull(@DepAPVBalanceAmt,0)    
    
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))     
  from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID     
  set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)    
    
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))     
  from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDatePair and AccountID=@AccountID    
  set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)    
    
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))     
  from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and    
  Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID    
  And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDatePair And ARVAbstract.ARVDate > @ToDatepair)    
  set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)    
  Set @TotalDepAmt=IsNull(@TotalDepAmt,0) + IsNull(@DepAmount,0)    
 End    
 Fetch Next From TotalAccount Into @AccountID    
End    
CLOSE TotalAccount    
DEALLOCATE TotalAccount     
Set @DepreciationValue=isnull(@TotalDepAmt,0)    
drop table #tempdepcomp 
