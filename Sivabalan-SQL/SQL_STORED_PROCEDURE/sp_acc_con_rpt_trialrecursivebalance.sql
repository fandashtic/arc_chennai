CREATE procedure sp_acc_con_rpt_trialrecursivebalance(@parentid integer,@fromdate datetime, @todate datetime,@balance decimal(18,2) output,@TotalDepAmt decimal(18,2) = 0 Output)    
as    
Set @balance=0    
Set @TotalDepAmt=0    
Create Table #temp(GroupID int,    
     Status int)    
Declare @GroupID int    
--Insert into #temp select GroupID, 0 From AccountGroup    
--Where ParentGroup = @parentid and GroupID <> @STOCKINTRADE    
Insert into #temp select GroupID, 0 From ConsolidateAccountGroup    
Where ParentGroup = @parentid --and isnull(Active,0)=1    
Declare Parent Cursor Dynamic For    
Select GroupID From #temp --Where Status = 0    
Open Parent    
Fetch From Parent Into @GroupID    
While @@Fetch_Status = 0    
Begin    
 Insert into #temp     
 Select GroupID, 0 From ConsolidateAccountGroup    
 Where ParentGroup = @GroupID --and isnull(Active,0)=1    
 --Update #temp Set Status = 1 Where GroupID = @GroupID    
 Fetch Next From Parent Into @GroupID    
End    
Close Parent    
DeAllocate Parent    
Declare @LastBalance decimal(18,2)    
Declare @AccountBalance decimal(18,2)    
Declare @AccountID Int,@Exists Int,@DepAmount Decimal(18,2),@TotDepAmt Decimal(18,2)    
Declare @CLOSINGSTOCK Int, @OPENINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int    
Set @CLOSINGSTOCK=23    
SET @OPENINGSTOCK=22    
Set @TAXONCLOSINGSTOCK=88    
Set @TAXONOPENINGSTOCK=89    
Insert into #temp values(@parentid,0)    
Declare scanrecursiveaccounts Cursor Keyset For    
Select AccountID from ConsolidateAccount where GroupID in (select groupid from #temp) and    
AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK)    
Open scanrecursiveaccounts    
Fetch From scanrecursiveaccounts Into @AccountID    
While @@Fetch_Status=0    
Begin    
 Set @AccountBalance=0    
 Exec sp_acc_con_rpt_fixedAssetrecursive @AccountID,@Exists output    
 If @Exists=1    
 Begin    
  Select @LastBalance= isNull(ClosingBalance,0),@DepAmount=IsNull(Depreciation,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1    
  Set @AccountBalance=IsNull(@LastBalance,0) - IsNull(@DepAmount,0)    
  Set @TotDepAmt=isnull(@TotDepAmt,0)+isnull(@DepAmount,0)    
 End    
 Else    
 Begin    
  If @AccountID=@OPENINGSTOCK or @AccountID=@TAXONOPENINGSTOCK    
  Begin    
   Select @LastBalance= isNull(OpeningBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1    
  End    
  Else    
  Begin    
   Select @LastBalance= isNull(ClosingBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1    
  End    
  Set @AccountBalance=@LastBalance    
 End    
 set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)    
 Fetch Next From scanrecursiveaccounts Into @AccountID    
End    
Set @balance=isnull(@balance,0)    
Set @TotalDepAmt=isnull(@TotDepAmt,0)    
Close scanrecursiveaccounts    
DeAllocate scanrecursiveaccounts    
Drop table #temp    

