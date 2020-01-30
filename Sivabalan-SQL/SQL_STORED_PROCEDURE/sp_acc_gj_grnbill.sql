CREATE Procedure sp_acc_gj_grnbill(@billid integer,@BackDate DATETIME=Null)  
as  
DECLARE @BILLSPAYABLE INT  
DECLARE @PURCHASE INT  
DECLARE @DOCTYPE INT  
DECLARE @value Decimal(18,6)  
DECLARE @documentid INT  
DECLARE @uniqueid INT  
DECLARE @grndate DATETIME  
DECLARE @grnid int  
  
Declare @Type Int  
Declare @GRN Int  
Declare @GRN_AMENDMENT Int  
Declare @GRNTYPE Int  
Declare @BillDate DateTime  
  
SET @BILLSPAYABLE = 27  
SET @PURCHASE = 34  
SET @DOCTYPE = 8  
SET @GRNTYPE = 41  
  
SET @GRN = 1  
SET @GRN_AMENDMENT = 2  
  
Declare @VAT_Receivable_DC Integer  
Declare @VatTaxamount decimal(18,6)  
Set @VAT_Receivable_DC  = 117  /* Constant to store the VAT Receivable on DC AccountID*/       

Create Table #TempBackdatedgrnbill(AccountID Int) --for backdated operation  
  
select @BillDate = BillDate from BillAbstract  
where [BillID]=@billid  
  
DECLARE scanGRN CURSOR KEYSET FOR  
Select GRNID from GRNAbstract where BillID=@billid  
OPEN scanGRN  
FETCH FROM scanGRN INTO @grnid  
While @@FETCH_STATUS=0  
Begin  
 If IsNull(@grnid,0) <> 0  
 Begin  
  select @value = max(Credit)  
  from GeneralJournal where isnull([DocumentReference],0)= @grnid  
  and isnull([DocumentType],0)in(41,66)  
  
  select @VatTaxamount = max(Debit)  
  from GeneralJournal where isnull([DocumentReference],0)= @grnid  
  and isnull([DocumentType],0)in(41,66) and AccountID = 117  
  Set @VatTaxAmount = IsNULL(@VatTaxAmount,0)
  
  -- Get the last TransactionID from the DocumentNumbers table  
  begin tran  
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24  
   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24  
  commit tran  
    
  begin tran  
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51  
   select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51  
  commit tran  
  
  If @value <> 0  
  Begin  
   insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
   Values(@documentid,@BILLSPAYABLE,@BillDate,@value,0,@grnid,@GRNTYPE,'Close GRN',@uniqueid,getdate())    
   Insert Into #TempBackdatedgrnbill(AccountID) Values(@BILLSPAYABLE)   
    
   insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
   [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
   Values(@documentid,@PURCHASE,@BillDate,0,@value - @VatTaxamount,@grnid,@GRNTYPE,'Close GRN',@uniqueid,getdate())    
   Insert Into #TempBackdatedgrnbill(AccountID) Values(@PURCHASE)   
   
   If @VatTaxAmount <> 0
   Begin
     insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
     [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
     Values(@documentid,@VAT_Receivable_DC,@BillDate,0,@VatTaxamount,@grnid,@GRNTYPE,'Close GRN',@uniqueid,getdate())    
     Insert Into #TempBackdatedgrnbill(AccountID) Values(@VAT_Receivable_DC)   
   End
  End
 End  
FETCH NEXT FROM scanGRN INTO @grnid   
End  
CLOSE scanGRN  
DEALLOCATE scanGRN  
  
If @BackDate Is Not Null    
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
 Select AccountID From #TempBackdatedgrnbill  
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
drop Table #TempBackdatedgrnbill
