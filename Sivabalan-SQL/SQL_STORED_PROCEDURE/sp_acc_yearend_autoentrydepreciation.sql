CREATE procedure sp_acc_yearend_autoentrydepreciation(@ToDate datetime)  
as  
Declare  @GroupID Int,@AccountID Int,@Balance Decimal(18,6),@TransactionID Int  
Declare @DepPercent as decimal(18,6),@DepAmount as decimal(18,6)  
DECLARE @FIXEDASSETGROUP INT  
DECLARE @DEPRECIATIONACCOUNT INT  
DECLARE @YEARENDTYPE INT  
Declare @DocumentNumber Int  
Declare @LastTranDate datetime  
Declare @ARVDate datetime  
Declare @ARVDocID Int  
Declare @PROFITONSALEOFASSET Int  
  
SET @FIXEDASSETGROUP=13  
SET @DEPRECIATIONACCOUNT=24  
SET @YEARENDTYPE=27  
Set @PROFITONSALEOFASSET =90  
  
Set @Todate=dbo.stripdatefromtime(@Todate)  
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation  
  
Create Table #temp(GroupID int)  
Insert into #temp select GroupID From AccountGroup Where ParentGroup = @FIXEDASSETGROUP and Active=1  
  
Declare Parent Cursor Dynamic For  
Select GroupID From #temp  
Open Parent  
Fetch From Parent Into @GroupID  
While @@Fetch_Status = 0  
Begin  
 Insert into #temp   
 Select GroupID From AccountGroup Where ParentGroup = @GroupID and Active=1  
 Fetch Next From Parent Into @GroupID  
End  
Close Parent  
DeAllocate Parent  
  
insert into #temp values(@FIXEDASSETGROUP)  
  
Declare @OpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)  
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@BatchCode Int  
  
Declare @YearStart Int,@FiscalYear Int,@OpeningDate DateTime,@StartDate DateTime,@EndDate DateTime  
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
  
Set @CheckDate =Cast(@StrDate As DateTime)  
set @CheckDate = DateAdd(m, 6, @CheckDate)  
set @CheckDate = DateAdd(d, 0-1, @CheckDate)  
  
Set @StartDate=Cast(@StrDate As DateTime)  
Set @EndDate=Cast(@StrDate As DateTime)  
set @EndDate = DateAdd(m, 12, @EndDate)  
set @EndDate = DateAdd(d, 0-1, @EndDate)  
  
Declare @LastBalance decimal(18,6)  
  
Declare TotalGroup Cursor Keyset For  
Select * from #Temp  
Open TotalGroup  
Fetch From TotalGroup Into @GroupID  
While @@Fetch_Status = 0  
Begin  
 Declare TotalAccount Cursor Keyset For  
 Select AccountID From AccountsMaster where GroupID=@GroupID and Active=1  
 Open TotalAccount  
 Fetch From TotalAccount Into @AccountID  
 While @@Fetch_Status = 0  
 Begin  
--   If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID = @AccountID)  
--   Begin  
--    Select @LastTranDate = Max(OpeningDate) from AccountOpeningBalance  
--    If @LastTranDate Is Not Null  
--    Begin  
--     Select @LastBalance = openingvalue from AccountOpeningBalance where OpeningDate=@LastTranDate and AccountID = @AccountID  
--    End  
--    Else  
--    Begin  
--     Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId =@AccountID and Active=1  
--     Select @LastTranDate = OpeningDate From Setup  
--    End  
--   End  
--   Else  
--   Begin   
--    set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@todate and AccountID = @AccountID),0)  
--    Set @LastTranDate = dbo.stripdatefromtime(@todate)  
--   End  
--   
--   set @Balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal   
--   where dbo.stripdatefromtime([TransactionDate]) between @LastTranDate and @todate and AccountID = @AccountID), 0)  
--     
--   set @Balance= IsNull(@Balance,0) + IsNull(@LastBalance,0)  
--   Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and Active=1),0)  
--   If @DepPercent>0   
--   Begin  
--    Set @DepAmount=@Balance * (@DepPercent/100)  
--    If @DepAmount > 0  
--    Begin  
--     -- Get the last TransactionID from the DocumentNumbers table  
--     begin tran  
--      update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
--      Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
--     Commit Tran   
--     begin tran  
--      update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
--      Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
--     Commit Tran  
--   
--     execute sp_acc_insertGJ @TransactionID,@DEPRECIATIONACCOUNT,@Todate,@DepAmount,0,0,@YearEndType,"Auto entry for depriciation",@DocumentNumber  
--     execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@DepAmount,0,@YearEndType,"Auto entry for depriciation",@DocumentNumber  
--    End  
--   End  
  Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)  
  If @DepPercent>0   
  Begin  
   DECLARE scanbatchassets CURSOR KEYSET FOR  
   Select BatchCode,IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End)   
   from Batch_Assets where AccountID=@AccountID and ( dbo.stripdatefromtime(APVDate) <= @EndDate or APVDate Is  Null)  
   and (IsNull(Saleable,0)=1 Or (IsNull(Saleable,0)=0 and (IsNull(ARVID,0)<>0 and (select dbo.StripDateFromTime(ARVDate) from ARVAbstract where ARVAbstract.DocumentID = Batch_Assets.ARVID)> @EndDate)))  
  End
  Else
  Begin  
   DECLARE scanbatchassets CURSOR KEYSET FOR  
   Select BatchCode,0 from Batch_Assets where AccountID=@AccountID and ( dbo.stripdatefromtime(APVDate) <= @EndDate or APVDate Is  Null)  
   and (IsNull(Saleable,0)=1 Or (IsNull(Saleable,0)=0 and (IsNull(ARVID,0)<>0 and (select dbo.StripDateFromTime(ARVDate) from ARVAbstract where ARVAbstract.DocumentID = Batch_Assets.ARVID)> @EndDate)))  
  End

  OPEN scanbatchassets  
  FETCH FROM scanbatchassets INTO @BatchCode,@DepAPVBalanceAmt  
  WHILE @@FETCH_STATUS=0  
  Begin  
   Update Batch_Assets Set DepPercent=IsNull(@DepPercent,0),DepAmount=IsNull(@DepAPVBalanceAmt,0),CWDV=(IsNull(OPWDV,0)-IsNull(@DepAPVBalanceAmt,0)),CummulativeDepAmt=(IsNull(CummulativeDepAmt,0)+IsNull(@DepAPVBalanceAmt,0)) Where BatchCode=@BatchCode  
   set @DepAmount=IsNull(@DepAmount,0) + IsNull(@DepAPVBalanceAmt,0)  
 
   --For certain critelia like sold an asset after fiscal year but that asset purchased before fiscal year  
   If exists(Select BatchCode from Batch_Assets Where AccountID=@AccountID and ( dbo.stripdatefromtime(APVDate) <= @EndDate or APVDate Is  Null)  
   and ((IsNull(Saleable,0)=0 and (IsNull(ARVID,0)<>0 and (select dbo.StripDateFromTime(ARVDate) from ARVAbstract where ARVAbstract.DocumentID = Batch_Assets.ARVID)> @EndDate))) )  
   Begin  
    select @ARVDocID =ARVAbstract.DocumentID,@ARVDate = dbo.StripDateFromTime(ARVDate) from ARVAbstract,Batch_Assets where ARVAbstract.DocumentID = Batch_Assets.ARVID and Batch_Assets.BatchCode=@BatchCode  
    -- Get the last TransactionID from the DocumentNumbers table  
    begin tran  
     update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
     Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
    Commit Tran   
    begin tran  
     update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
     Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
    Commit Tran  
    
    If IsNull(@DepAPVBalanceAmt,0)<>0  
    Begin  
     execute sp_acc_insertGJ @TransactionID,@AccountID,@ARVDate,@DepAPVBalanceAmt,0,@ARVDocID,48,"Profit on sale of asset-Yearend",@DocumentNumber --48 -> ARVType  
     execute sp_acc_insertGJ @TransactionID,@PROFITONSALEOFASSET,@ARVDate,0,@DepAPVBalanceAmt,@ARVDocID,48,"Profit on sale of asset-Yearend",@DocumentNumber --48 -> ARVType  
     Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)   
     Insert Into #TempBackdatedAccounts(AccountID) Values(@PROFITONSALEOFASSET)   
    End  
   End  
   FETCH NEXT FROM scanbatchassets INTO @BatchCode,@DepAPVBalanceAmt  
  End  
  CLOSE scanbatchassets  
  DEALLOCATE scanbatchassets  

  -- Get the last TransactionID from the DocumentNumbers table  
  begin tran  
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
   Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
  Commit Tran   
  begin tran  
   update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
   Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
  Commit Tran  
   
  If IsNull(@DepAmount,0)<>0  
  Begin  
   execute sp_acc_insertGJ @TransactionID,@DEPRECIATIONACCOUNT,@Todate,@DepAmount,0,0,@YearEndType,"Auto entry for depriciation",@DocumentNumber  
   execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@DepAmount,0,@YearEndType,"Auto entry for depriciation",@DocumentNumber  
   Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)   
  End  
 
  Set @LastBalance = 0  
  Set @Balance = 0  
  Set @LastTranDate = Null  
  Set @DepAmount=0  
  Set @DepPercent=0  
  Fetch Next From TotalAccount Into @AccountID  
 End  
 CLOSE TotalAccount  
 DEALLOCATE TotalAccount   
 Fetch Next From TotalGroup Into @GroupID  
End  
CLOSE TotalGroup  
DEALLOCATE TotalGroup  
drop table #temp  
  
Insert Into #TempBackdatedAccounts(AccountID) Values(@DEPRECIATIONACCOUNT) --Instead of insert this account in loop insert outside of the loop for backdated transactions.  
  
/*Backdated Operation */  
--Get the server date  
Declare @ServerDate Datetime  
set @ServerDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
  
If @ToDate < @ServerDate  
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
 Select AccountID From #TempBackdatedAccounts  
 OPEN scantempbackdatedaccounts  
 FETCH FROM scantempbackdatedaccounts INTO @TempAccountID  
 WHILE @@FETCH_STATUS =0  
 Begin  
  Exec sp_acc_backdatedaccountopeningbalance @TODATE,@TempAccountID  
  FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID  
 End  
 CLOSE scantempbackdatedaccounts  
 DEALLOCATE scantempbackdatedaccounts  
 Drop Table #TempBackdatedAccounts  
End 

