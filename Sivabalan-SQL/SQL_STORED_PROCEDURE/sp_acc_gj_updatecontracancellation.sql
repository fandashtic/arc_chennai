CREATE procedure sp_acc_gj_updatecontracancellation(@contraid integer,@BackDate DATETIME=Null)        
as        
DECLARE @value decimal(18,6)        
DECLARE @accountid integer        
DECLARE @ToAccountID integer        
DECLARE @transactiontype integer        
DECLARE @depositdate datetime        
DECLARE @documentid integer        
DECLARE @uniqueid integer        
            
DECLARE @CASH integer        
DECLARE @PETTYCASH integer        
DECLARE @CASHDEPOSIT integer        
DECLARE @CASHWITHDRAWL integer        
DECLARE @TOPETTYCASH integer        
DECLARE @FROMPETTYCASH integer        
DECLARE @ACCOUNT_TRANSFER INT        
DECLARE @DOCTYPE integer        
        
SET @CASH =3        
SET @PETTYCASH =4         
        
SET @CASHDEPOSIT =1        
SET @CASHWITHDRAWL =2        
SET @TOPETTYCASH=3        
SET @FROMPETTYCASH=4        
SET @ACCOUNT_TRANSFER=6        
SET @DOCTYPE =38 --Deposit Type        
        
Create Table #TempBackdatedContra(AccountID Int) --for backdated operation        
        
select @accountid =[AccountID],@value = [Value],@transactiontype = [TransactionType],        
@depositdate = [DepositDate],@ToAccountID = [ToAccountID] from Deposits where [DepositID]=@contraid        
        
if @transactiontype = @CASHDEPOSIT        
begin        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24        
    select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24        
 commit tran        
        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51        
    select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51        
 commit tran        
        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@CASH,@depositdate,@value,0,@contraid,@DOCTYPE,'Cash deposited in bank - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@CASH)         
         
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@accountid,@depositdate,0,@value,@contraid,@DOCTYPE,'Cash deposited in bank - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@accountid)        
end        
else if @transactiontype = @CASHWITHDRAWL        
begin        
         
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24        
    select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24        
 commit tran        
        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51        
    select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51        
 commit tran        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@accountid,@depositdate,@value,0,@contraid,@DOCTYPE,'Cash withdrawl from bank - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@accountid)        
         
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@CASH,@depositdate,0,@value,@contraid,@DOCTYPE,'Cash withdrawl from bank - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@CASH)        
end        
else if @transactiontype = @TOPETTYCASH        
begin        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24        
    select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24        
 commit tran        
        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51        
    select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51        
 commit tran        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@CASH,@depositdate,@value,0,@contraid,@DOCTYPE,'Cash paid to petty cash - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@CASH)        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@PETTYCASH,@depositdate,0,@value,@contraid,@DOCTYPE,'Cash paid to petty cash - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@PETTYCASH)        
end        
else if @transactiontype = @FROMPETTYCASH        
begin        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24        
    select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24        
 commit tran        
        
 begin tran        
    update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51        
    select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51        
 commit tran        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@PETTYCASH,@depositdate,@value,0,@contraid,@DOCTYPE,'Cash receieved from petty cash - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@PETTYCASH)        
        
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],        
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])        
 Values(@documentid,@CASH,@depositdate,0,@value,@contraid,@DOCTYPE,'Cash receieved from petty cash - cancelled',@uniqueid)          
 Insert Into #TempBackdatedContra(AccountID) Values(@CASH)        
end        
else if @transactiontype = @ACCOUNT_TRANSFER          
 begin          
  begin tran          
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24          
   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24          
  commit tran          
          
  begin tran          
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51          
   select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51          
  commit tran          
          
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])          
  Values(@documentid,@accountid,@depositdate,@value,0,@contraid,@DOCTYPE,'Internal Bank Transfer-Cancelled',@uniqueid)            
  Insert Into #TempBackdatedContra(AccountID) Values(@accountid)          
        
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],          
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])          
  Values(@documentid,isnull(@ToAccountID,0),@depositdate,0,@value,@contraid,@DOCTYPE,'Internal Bank Transfer-Cancelled',@uniqueid)            
  Insert Into #TempBackdatedContra(AccountID) Values(@ToAccountID)          
 end        
        
If @BackDate Is Not Null          
Begin        
 Declare @TempAccountID Int        
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR        
 Select AccountID From #TempBackdatedContra        
 OPEN scantempbackdatedaccounts        
 FETCH FROM scantempbackdatedaccounts INTO @TempAccountID        
 WHILE @@FETCH_STATUS =0        
 Begin        
  Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID        
  FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID    
 End        
 CLOSE scantempbackdatedaccounts        
 DEALLOCATE scantempbackdatedaccounts        
End        
Drop Table #TempBackdatedContra        
  

