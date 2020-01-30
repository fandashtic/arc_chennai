CREATE Procedure sp_acc_yearend_recursiveaccountsetting(@parentid integer,@ContraAccount Int,@todate datetime,@YearEndType Int)  
as  
Declare @GroupID Int,@AccountID Int,@Balance Decimal(18,6),@TransactionID Int  
DECLARE @PURCHASEGROUP INT,@SALESGROUP INT,@DIRECTEXPENSEGROUP INT,@DIRECTINCOMEGROUP INT  
DECLARE @INDIRECTEXPENSEGROUP INT,@INDIRECTINCOMEGROUP INT  
Declare @LastTranDate DateTime,@DocumentNumber Int  
SET @PURCHASEGROUP=27  
SET @SALESGROUP=28  
SET @DIRECTEXPENSEGROUP=24  
SET @INDIRECTEXPENSEGROUP=25  
SET @DIRECTINCOMEGROUP=26  
SET @INDIRECTINCOMEGROUP=31  
  
Create Table #TempBackdatedRecursiveAccounts(AccountID Int) --for backdated operation  
  
Create Table #temp(GroupID int)  
Insert into #temp select GroupID From AccountGroup Where ParentGroup = @parentid and Active=1  
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
Declare @LastBalance decimal(18,6)  
insert into #temp values(@parentid)  
  
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
  If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID = @AccountID)  
  Begin  
   Select @LastTranDate=max(OpeningDate) from AccountOpeningBalance Where OpeningDate < @todate And AccountID = @AccountID 
   if @LastTranDate Is Null  
   Begin  
    Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId =@AccountID and Active=1  
    Select @LastTranDate = OpeningDate From Setup  
   End  
   Else  
   Begin  
    Select @LastBalance = IsNull(openingvalue,0) from AccountOpeningBalance where OpeningDate= @LastTranDate and AccountID = @AccountID  
   End  
   --Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId in (select [AccountID] from [AccountsMaster] where [GroupID] in (select groupid from #temp))  
  End  
  Else  
  Begin   
   set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@todate and AccountID = @AccountID),0)  
   Set @LastTrandate = dbo.stripdatefromtime(@todate)  
  End  
  
  set @Balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal   
  where dbo.stripdatefromtime([TransactionDate]) between @LastTranDate and @todate and AccountID = @AccountID   
  and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63) and isnull(status,0) <> 128 and isnull(status,0) <> 192), 0)   
      
  set @Balance=IsNull(@Balance,0) + IsNull(@LastBalance,0)  
  --Select "Ac"=@AccountID,@Balance,@LastBalance  
  If @Balance > 0  
  Begin  
   Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@ContraAccount)   
   -- Get the last TransactionID from the DocumentNumbers table  
   begin tran  
    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
    Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
   Commit Tran   
   -- Get the last TransactionID from the DocumentNumbers table  
   begin tran  
    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
    Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
   Commit Tran   
  
   If @ParentID=@PURCHASEGROUP or @ParentID=@DIRECTEXPENSEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
      
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
   Else If @ParentID=@SALESGROUP or @ParentID=@DIRECTINCOMEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
  
   If  @ParentID=@INDIRECTEXPENSEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
   Else If @ParentID=@INDIRECTINCOMEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
  
  
  End  
  Else If @Balance < 0   
  Begin  
   Set @Balance=abs(@Balance)  
     
   Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@ContraAccount)   
   -- Get the last TransactionID from the DocumentNumbers table  
   begin tran  
    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
    Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
   Commit Tran   
   -- Get the last TransactionID from the DocumentNumbers table  
   begin tran  
    update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
    Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
   Commit Tran   
   If @ParentID=@PURCHASEGROUP or @ParentID=@DIRECTEXPENSEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
   Else If @ParentID=@SALESGROUP or @ParentID=@DIRECTINCOMEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
   If @ParentID=@INDIRECTEXPENSEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
   Else If @ParentID=@INDIRECTINCOMEGROUP  
   Begin  
    execute sp_acc_insertGJ @TransactionID,@ContraAccount,@Todate,0,@Balance,0,@YearEndType,"Year End",@DocumentNumber  
    execute sp_acc_insertGJ @TransactionID,@AccountID,@Todate,@Balance,0,0,@YearEndType,"Year End",@DocumentNumber  
  
    Insert Into #TempBackdatedRecursiveAccounts(AccountID) Values(@AccountID)   
   End  
  
  End  
  Set @LastBalance = 0  
  Set @Balance = 0  
  Set @LastTranDate = Null  
  Fetch Next From TotalAccount Into @AccountID  
 End  
 CLOSE TotalAccount  
 DEALLOCATE TotalAccount   
 Fetch Next From TotalGroup Into @GroupID  
End  
CLOSE TotalGroup  
DEALLOCATE TotalGroup  
drop table #temp  
  
/*Backdated Operation */  
--Get the server date  
Declare @ServerDate Datetime  
set @ServerDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
  
If @ToDate < @ServerDate  
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedrecursiveaccounts CURSOR KEYSET FOR  
 Select AccountID From #TempBackdatedRecursiveAccounts  
 OPEN scantempbackdatedrecursiveaccounts  
 FETCH FROM scantempbackdatedrecursiveaccounts INTO @TempAccountID  
 WHILE @@FETCH_STATUS =0  
 Begin  
  Exec sp_acc_backdatedaccountopeningbalance @TODATE,@TempAccountID  
  FETCH NEXT FROM scantempbackdatedrecursiveaccounts INTO @TempAccountID  
 End  
 CLOSE scantempbackdatedrecursiveaccounts  
 DEALLOCATE scantempbackdatedrecursiveaccounts  
 Drop Table #TempBackdatedRecursiveAccounts  
End 

