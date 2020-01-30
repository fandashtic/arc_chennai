CREATE Procedure sp_acc_gj_claimssettlement(@claimid integer,@BackDate DATETIME=Null)  
As  
DECLARE @nclaimid integer, @nClaimType integer,@dclaimdate datetime,@nvendorid nvarchar(15)  
DECLARE @nclaimvalue decimal (18,6),@claimsreceivable integer,@SecondarySchemeExpense integer,@documentid integer  
DECLARE @ndoctype integer,@accountid integer  
declare @uniqueid integer  
  
set @claimsreceivable =10  /*constant to store claimsreceivable Account*/   
set @SecondarySchemeExpense=39  /*constant to store secondary scheme expenses Account*/   
set @ndoctype=23   /*constant to store document type Account*/   
set @accountid=0  /*constant to store the vendors AccountID*/   
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation  
  
select @nclaimid =[ClaimID], @nClaimType = IsNull(ClaimType,0), @dclaimdate =[SettlementDate],@nclaimvalue =[SettlementValue],@nvendorid=[VendorID]  
from claimsnote Where ClaimID=@claimid  
  
select @accountid=isnull([AccountID],0) from Vendors where [VendorID]=@nvendorid  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24  
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24  
commit tran  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51  
 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51  
commit tran  
  
if @nclaimvalue <> 0  
begin  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
 Values(@documentid,@accountid,@dclaimdate,@nclaimvalue,0,@claimid,@ndoctype,'Claims Raise Settlement',@uniqueid)    
 Insert Into #TempBackdatedAccounts(AccountID) Values(@accountid)  
end  
  
if @nclaimvalue <> 0  
begin  
 If (@nClaimType=4) Or (@nClaimType=6) -- Secondary Scheme  
 Begin  
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
  Values(@documentid,@SecondarySchemeExpense,@dclaimdate,0,@nclaimvalue,@claimid,@ndoctype,'Claims Raise Settlement',@uniqueid)  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@SecondarySchemeExpense)  
 End  
 Else  
 Begin  
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])  
  Values(@documentid,@claimsreceivable,@dclaimdate,0,@nclaimvalue,@claimid,@ndoctype,'Claims Raise Settlement',@uniqueid)  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@claimsreceivable)  
 End    
end  
  
/*Backdated Operation */  
If @BackDate Is Not Null    
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
 Select AccountID From #TempBackdatedAccounts  
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
Drop Table #TempBackdatedAccounts 
