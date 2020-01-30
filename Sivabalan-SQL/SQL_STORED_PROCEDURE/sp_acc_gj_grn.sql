CREATE procedure sp_acc_gj_grn(@grnid integer,@BackDate DATETIME=Null)
as
DECLARE @BILLSPAYABLE INT
DECLARE @PURCHASE INT
DECLARE @DOCTYPE INT
DECLARE @value Decimal(18,6)
DECLARE @TaxValue Decimal(18,6)
DECLARE @documentid INT
DECLARE @uniqueid INT
DECLARE @grndate DATETIME

SET @BILLSPAYABLE = 27
SET @PURCHASE = 34
SET @DOCTYPE = 41

Declare @Vat_Exists Integer
Declare @VAT_Receivable_DC Integer
Declare @VatTaxamount decimal(18,6)
Set @VAT_Receivable_DC  = 117  /* Constant to store the VAT Receivable on DC AccountID*/     
Set @Vat_Exists = 0 
If dbo.columnexists('Items','VAT') = 1
Begin
	Set @Vat_Exists = 1
end

Create Table #TempBackdatedgrn(AccountID Int) --for backdated operation

select @grndate = [GRNDate] from GRNAbstract where GRNID=@grnid

/*select @value = sum((isnull([GRNDetail].[QuantityReceived],0)- isnull([GRNDetail].[QuantityRejected],0))*  isnull([Batch_Products].[PurchasePrice],0))
from GrnDetail,Batch_Products where [GrnDetail].[GRNID]=@grnid
and [GrnDetail].[GRNID] = [Batch_Products].[GRN_ID] 
and [GrnDetail].[Product_Code]=[Batch_Products].[Product_Code]*/

select @value = sum(isnull([QuantityReceived],0) *  isnull([PurchasePrice],0))
from Batch_Products where [Batch_Products].[GRN_ID]=@grnid 
and isnull([Batch_Products].[Free],0)<>1

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

If @value <> 0
Begin 
	If @Vat_Exists  = 1
	Begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
		Values(@documentid,@PURCHASE,@grndate,@value - @VatTaxamount,0,@grnid,@DOCTYPE,'GRN',@uniqueid,getdate())  
		Insert Into #TempBackdatedgrn(AccountID) Values(@PURCHASE) 

		If @VatTaxamount > 0 
		Begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
			Values(@documentid,@VAT_Receivable_DC,@grndate,@VatTaxamount,0,@grnid,@DOCTYPE,'GRN',@uniqueid,getdate())  
			Insert Into #TempBackdatedgrn(AccountID) Values(@VAT_Receivable_DC) 
		End
	End
	Else
	Begin
		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
		Values(@documentid,@PURCHASE,@grndate,@value,0,@grnid,@DOCTYPE,'GRN',@uniqueid,getdate())  
		Insert Into #TempBackdatedgrn(AccountID) Values(@PURCHASE) 
	End

	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	Values(@documentid,@BILLSPAYABLE,@grndate,0,@value,@grnid,@DOCTYPE,'GRN',@uniqueid,getdate())  
	Insert Into #TempBackdatedgrn(AccountID) Values(@BILLSPAYABLE) 
End

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedgrn
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
Drop Table #TempBackdatedgrn


