CREATE Procedure sp_acc_gj_grnamendment(@grnid integer,@BackDate DATETIME=Null)  
as  
DECLARE @BILLSPAYABLE INT  
DECLARE @PURCHASE INT  
DECLARE @DOCTYPE INT  
DECLARE @AMENDMENTTYPE INT  
DECLARE @value Decimal(18,6)  
DECLARE @TaxValue Decimal(18,6)  
DECLARE @documentid INT  
DECLARE @uniqueid INT  
DECLARE @grndate DATETIME  
DECLARE @amendedid int  
DECLARE @amendedvalue decimal(18,6)  
DECLARE @amendeddate datetime  
   
SET @BILLSPAYABLE = 27  
SET @PURCHASE = 34  
SET @DOCTYPE = 41  
SET @AMENDMENTTYPE = 66  
  
Declare @Vat_Exists Integer  
Declare @VAT_Receivable_DC Integer  
Declare @VatTaxamount decimal(18,6)  
Declare @AmendedVatTaxamount decimal(18,6)  
Set @VAT_Receivable_DC  = 117  /* Constant to store the VAT Receivable on DC AccountID*/       
Set @Vat_Exists = 0   
If dbo.columnexists('Items','VAT') = 1  
Begin  
 Set @Vat_Exists = 1  
end  
  
Create Table #TempBackdatedgrnamendment(AccountID Int) --for backdated operation  
  
select @grndate = [GRNDate],@amendedid = GRNIDRef   
from GRNAbstract where [GRNID] = @grnid   
  
If @Vat_Exists  = 1  
Begin  
 select @amendedvalue = max(Debit),@amendeddate = max(TransactionDate)   
 from GeneralJournal where [DocumentReference]= @amendedid  
 and [DocumentType]in (41,66) and AccountID <> 117  
  
 select @AmendedVatTaxamount = max(Debit)  
 from GeneralJournal where [DocumentReference]= @amendedid  
 and [DocumentType]in (41,66) and AccountID = 117  
End  
Else  
Begin  
 select @amendedvalue = max(Debit),@amendeddate = max(TransactionDate)   
 from GeneralJournal where [DocumentReference]= @amendedid  
 and [DocumentType]in (41,66)  
End  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24  
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24  
commit tran  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51  
 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51  
commit tran  
  
If @Vat_Exists  = 1  
Begin  
 Set @AmendedVatTaxamount = isnull(@AmendedVatTaxamount,0)  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@BILLSPAYABLE,@amendeddate,@amendedvalue + @AmendedVatTaxamount,0,@amendedid,@AMENDMENTTYPE,'GRN - Amended',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrnamendment(AccountID) Values(@BILLSPAYABLE)   
End  
Else  
Begin  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@BILLSPAYABLE,@amendeddate,@amendedvalue,0,@amendedid,@AMENDMENTTYPE,'GRN - Amended',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrnamendment(AccountID) Values(@BILLSPAYABLE)   
End  
insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
Values(@documentid,@PURCHASE,@amendeddate,0,@amendedvalue,@amendedid,@AMENDMENTTYPE,'GRN - Amended',@uniqueid,getdate())    
Insert Into #TempBackdatedgrnamendment(AccountID) Values(@PURCHASE)   
  
If @Vat_Exists  = 1  
Begin  
 If @AmendedVatTaxamount > 0   
 Begin   
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  Values(@documentid,@VAT_Receivable_DC,@amendeddate,0,@AmendedVatTaxamount,@amendedid,@AMENDMENTTYPE,'GRN - Amended',@uniqueid,getdate())    
  Insert Into #TempBackdatedgrnamendment(AccountID) Values(@VAT_Receivable_DC)   
 End  
End  
  
select @value = sum(isnull([QuantityReceived],0) *  isnull([PurchasePrice],0))  
from Batch_Products where [Batch_Products].[GRN_ID]=@grnid and isnull([Batch_Products].[Free],0)<>1  
  
Select @TaxValue = Sum((IsNULL(QuantityReceived,0) * IsNULL(PurchasePrice,0)) * (IsNULL(TaxSuffered,0)/100))  
from Batch_Products where [Batch_Products].[GRN_ID]=@grnid And isnull([Batch_Products].[Free],0)<>1  
  
If @Vat_Exists  = 1  
Begin  
 Set @VatTaxamount = 0  
 Select   
 @VatTaxamount = isnull(Sum((IsNULL(B.QuantityReceived,0) * IsNULL(B.PurchasePrice,0)) * (IsNULL(B.TaxSuffered,0)/100)),0)  
 from Batch_Products B,Items I   
 where   
 B.GRN_ID= @grnid And   
 isnull(B.[Free],0)<> 1 And  
 I.Product_Code = B.Product_Code And  
 I.Vat = 1 and  
 (Select Locality From Vendors where VendorID in   
  (Select VendorID from GRNAbstract where GRNID = @grnid)) = 1  
End  
  
Set @value = @value + IsNull(@TaxValue,0)  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24  
 select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24  
commit tran  
  
begin tran  
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51  
 select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51  
commit tran  
  
If @Vat_Exists  = 1  
Begin   
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@PURCHASE,@grndate,@value - @VatTaxamount,0,@grnid,@AMENDMENTTYPE,'GRN Amendment',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrnamendment(AccountID) Values(@PURCHASE)   
  
 If @VatTaxamount > 0   
 Begin  
  insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
  [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
  Values(@documentid,@VAT_Receivable_DC,@grndate,@VatTaxamount,0,@grnid,@AMENDMENTTYPE,'GRN Amendment',@uniqueid,getdate())    
  Insert Into #TempBackdatedgrnamendment(AccountID) Values(@VAT_Receivable_DC)   
 End  
End  
Else  
Begin  
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
 Values(@documentid,@PURCHASE,@grndate,@value,0,@grnid,@AMENDMENTTYPE,'GRN Amendment',@uniqueid,getdate())    
 Insert Into #TempBackdatedgrnamendment(AccountID) Values(@PURCHASE)   
End  
  
insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],  
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])  
Values(@documentid,@BILLSPAYABLE,@grndate,0,@value,@grnid,@AMENDMENTTYPE,'GRN Amendment',@uniqueid,getdate())    
Insert Into #TempBackdatedgrnamendment(AccountID) Values(@BILLSPAYABLE)   
  
If @BackDate Is Not Null    
Begin  
 Declare @TempAccountID Int  
 DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR  
 Select AccountID From  #TempBackdatedgrnamendment  
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
Drop Table  #TempBackdatedgrnamendment 
