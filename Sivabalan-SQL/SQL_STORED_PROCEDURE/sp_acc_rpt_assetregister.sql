CREATE procedure sp_acc_rpt_assetregister(@FromDate datetime, @ToDate datetime)      
as      
      
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
Declare @status nvarchar(50)
    
Declare @ToDatePair datetime    
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))      
    
Declare @DepRate decimal(18,6)      
Declare @CurrentValue decimal(18,6)      
      
DECLARE @FIXEDASSETGROUP INT,@DEPRECIATION INT      
SET @FIXEDASSETGROUP=13      
SET @DEPRECIATION=24      
      
Create Table #TempDepreciation(rownum int identity(1,1),
Asset nvarchar(50),DepRate decimal(18,6),CurrentValue decimal(18,6),AccountID Int,
Status nvarchar(50),colorinfo int)        


Create Table #temp(GroupID int)      
      
Insert into #temp select GroupID From AccountGroup Where ParentGroup = @FIXEDASSETGROUP --and Active=1      
Declare Parent Cursor Dynamic For      
Select GroupID From #temp      
Open Parent      
Fetch From Parent Into @GroupID      
While @@Fetch_Status = 0      
Begin      
 Insert into #temp       
 Select GroupID From AccountGroup Where ParentGroup = @GroupID --and Active=1      
 Fetch Next From Parent Into @GroupID      
End      
Close Parent      
DeAllocate Parent      
      
Insert into #temp values(@FIXEDASSETGROUP)      
      
Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)      
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@APVBalanceAmt Decimal(18,6),@StartDate DateTime,@EndDate DateTime      
Set @StrDate=dbo.sp_acc_getfiscalyearstart()      
Set @CheckDate =Cast(@StrDate As DateTime)      
set @CheckDate = DateAdd(m, 6, @CheckDate)      
set @CheckDate = DateAdd(s, 0-1, @CheckDate)      
      
Set @StartDate=Cast(@StrDate As DateTime)      
Set @EndDate=Cast(@StrDate As DateTime)      
set @EndDate = DateAdd(m, 12, @EndDate)      
set @EndDate = DateAdd(d, 0-1, @EndDate)      
      
      
Declare TotalAccount Cursor Keyset For      
Select AccountID,AccountName,AdditionalField1,
'Status' =
	case
		when isnull(active,0) = 0 then dbo.LookupDictionaryItem('In-Active',Default)
		when isnull(active,0) = 1 then dbo.LookupDictionaryItem('Active',Default)
	end
From AccountsMaster where GroupID in (Select * from #Temp) --and Active=1      
Open TotalAccount      
Fetch From TotalAccount Into @AccountID,@AccountName,@DepRate,@status
      
While @@Fetch_Status = 0      
Begin      
 Select @OpeningBalance = Sum(IsNull(OPWDV,0)) from Batch_Assets       
 where AccountID=@AccountID and       
 ((IsNull(APVID,0)=0 and CreationTime < @StartDate and IsNull(Saleable,0)=1) Or      
 (IsNull(APVID,0)=0 and CreationTime >= @StartDate) Or      
 (IsNull(APVID,0)<>0 and APVDate < @StartDate and IsNull(Saleable,0)=1 ) Or      
 (isnull(ARVID,0)<>0 and IsNull(Saleable,0)=0 and CreationTime < @StartDate And (select ARVDate from ARVAbstract where ARVAbstract.Documentid=Batch_Assets.ARVID) Between @StartDate and @ToDatePair))      
 Select @Additions = Sum(IsNull(OPWDV,0)) from Batch_Assets       
 where IsNull(Saleable,0) in (0,1) and AccountID=@AccountID and (IsNull(APVID,0)<> 0 and (APVDate Between @StartDate and @ToDatePair))      
 Select @Sales = Sum(IsNull(OPWDV,0)) from Batch_Assets       
 where IsNull(Saleable,0)=0 and AccountID=@AccountID and ((Select ARVDate from ARVAbstract where ARVAbstract.DocumentID = Batch_Assets.ARVID) between @StartDate and @ToDatePair)       
      
 Set @ClosingBalanceBeforeDepriciation=IsNull(@OpeningBalance,0)+IsNull(@Additions,0)-IsNull(@Sales,0)      
 Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)      
 If @DepPercent>0       
 Begin      
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))      
  from Batch_Assets where IsNull(Saleable,0)=1 and AccountID=@AccountID and (APVDate Is Not Null  and (APVDate <= @ToDatePair))      
  Set @DepAmount=IsNull(@DepAPVBalanceAmt,0)      
  Select @DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))      
  from Batch_Assets where IsNull(Saleable,0)=1 and AccountID=@AccountID and APVDate Is Null      
  Set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)      
  Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation-@DepAmount      
 End      
 Else      
 Begin      
  Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation      
 End      
      
 Insert Into #TempDepreciation values
 (@AccountName,IsNull(@DepPercent,0),IsNull(@ClosingBalanceAfterDepriciation,0),@AccountID,@status,'0')      

 Set @DepPercent=0      
 Set @ClosingBalanceAfterDepriciation=0      
 Fetch Next From TotalAccount Into @AccountID,@AccountName,@DepRate,@status
End      
CLOSE TotalAccount      
DEALLOCATE TotalAccount       

insert into #TempDepreciation
select 'Total' , null,sum(CurrentValue),null,null,1 from #TempDepreciation

Select "Name of Asset"=Asset,"Current Value"=CurrentValue,
Status,@Fromdate,@Todate,AccountID,colorinfo from #TempDepreciation 
order by rownum


drop table #temp      
drop table #TempDepreciation 





