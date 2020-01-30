CREATE Procedure sp_acc_gj_grncancellation(@grnid integer,@BackDate DATETIME=Null)  
as  
DECLARE @BILLSPAYABLE INT  
DECLARE @PURCHASE INT  
DECLARE @DOCTYPE INT  
DECLARE @value Decimal(18,6)  
DECLARE @documentid INT  
DECLARE @uniqueid INT  
DECLARE @grndate DATETIME  
Declare @Status Int  
  
SET @BILLSPAYABLE = 27  
SET @PURCHASE = 34  
SET @DOCTYPE = 42  
  
Declare @VAT_Receivable_DC Integer  
Declare @VatTaxamount decimal(18,6)  
Set @VAT_Receivable_DC  = 117  /* Constant to store the VAT Receivable on DC AccountID*/       
  
Create Table #TempBackdatedgrncancellation(AccountID Int) --for backdated operation  
  
Select @Status = IsNull(GRNStatus,0)from GRNAbstract  
Where GRNID = @grnid  
  
-- If (@Status & 16) <> 0   
-- Begin  
--  select @value = max(Debit), @grndate = max(TransactionDate)  
--  from GeneralJournal where isnull([DocumentReference],0)= @grnid  
--  and isnull([DocumentType],0)= 66  
-- End  
-- Else  
-- Begin  
--  select @value = max(Debit), @grndate = max(TransactionDate)  
--  from GeneralJournal where isnull([DocumentReference],0)= @grnid  
--  and isnull([DocumentType],0)= 41  
-- End  
  
select @value = max(Credit), @grndate = max(TransactionDate)  
from GeneralJournal where isnull([DocumentReference],0)= @grnid  
and isnull([DocumentType],0)in(41,66)  

select @VatTaxamount = max(Debit)  
from GeneralJournal where isnull([DocumentReference],0)= @grnid  
and isnull([DocumentType],0)in(41,66) and AccountID = 117  
Set @VatTaxamount = IsNULL(@VatTaxamount,0)
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24  
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24  
commit tran  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51  
 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51  
commit tran  
  
If @value <> 0  
begin  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@BILLSPAYABLE,@grndate,@value,0,@grnid,@DOCTYPE,'GRN Cancellation',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrncancellation(AccountID) Values(@BILLSPAYABLE)   
  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@PURCHASE,@grndate,0,@value - @VatTaxamount,@grnid,@DOCTYPE,'GRN Cancellation',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrncancellation(AccountID) Values(@PURCHASE)   
  
 If @VatTaxamount > 0   
 Begin  
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  Values(@documentid,@VAT_Receivable_DC,@grndate,0,@VatTaxamount ,@grnid,@DOCTYPE,'GRN Cancellation',@uniqueid,getdate())    
  Insert Into #TempBackdatedgrncancellation(AccountID) Values(@VAT_Receivable_DC)   
 End  
End  
  
If @BackDate Is Not Null    
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
 Select AccountID From #TempBackdatedgrncancellation  
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
Drop Table #TempBackdatedgrncancellation
