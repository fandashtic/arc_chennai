CREATE Procedure sp_acc_gj_stocktransferoutamendment (@DocSerial INT,@BackDate DATETIME=Null)  
AS  
--Journal entry for Retail Invoice  
Declare @DocumentDate datetime  
Declare @NetValue float  
Declare @TaxAmount float  
Declare @BranchID nvarchar(25)  
Declare @AccountID int  
Declare @TransactionID int  
Declare @DocumentNumber int  
Declare @Reference int  
  
Declare @AccountID1 int  
Declare @AccountID2 int  
Set @AccountID1 = 37  --StockTransferOut Account  
Set @AccountID2 = 38  --Tax on StockTransfer Account  
  
Declare @AccountType Int  
Set @AccountType =70  
  
Declare @Vat_Exists Integer  
Declare @VAT_Payable Integer  
Declare @FLSTTaxType Integer
Declare @FLSTTax decimal(18,6)
Declare @nVatTaxamount decimal(18,6)  
Set @VAT_Payable  = 116  /* Constant to store the VAT Payable (Output Tax) AccountID*/       
Set @Vat_Exists = 0   
If dbo.columnexists('StockTransferOutAbstract','VATTaxAmount') = 1  
Begin  
 Set @Vat_Exists = 1  
end  
  
Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation  
  
If @Vat_Exists  = 1  
Begin  
 Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),  
 @TaxAmount=IsNull(TaxAmount,0)-isnull(VATTaxAmount,0),@BranchID=WareHouseID, 
 @Reference= (case When isnull(STOIDRef,0) = 0 Then isnull(DocSerial,0) Else isnull(STOIDRef,0) End),@nVatTaxamount = isnull(VATTaxAmount,0)
 from StockTransferOutAbstract where DocSerial=@DocSerial  

select @FLSTTax = Sum(Isnull(STO.TaxAmount,0))
from StockTransferOutdetail STO ,Batch_products B
Where STO.Batch_Code = B.Batch_Code 
And STO.DocSerial = @DocSerial And B.TaxType In(3,4)

If Isnull(@FLSTTax,0) <> 0 
	Begin
		set @FLSTTaxType = 3 -- FLST/FMRP (3 or 4)
	End

End  
Else  
Begin  
 Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),  
 @TaxAmount=IsNull(TaxAmount,0),@BranchID=WareHouseID,  
 @Reference=isnull(STOIDRef,0)   
 from StockTransferOutAbstract where DocSerial=@DocSerial  
End  
-- Get AccountID of the branch from Branch master  
Select @AccountID=isnull(AccountID,0) from WareHouse where WareHouseID=@BranchID  
  
-- Get the last TransactionID from the DocumentNumbers table  
begin tran  
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
Commit Tran  
begin tran  
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
Commit Tran  
  
Declare @PurchaseValue float  
If @Vat_Exists  = 1  
	If @FLSTTaxType in(3,4)
		Begin
			SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0) + isnull(@FLSTTax,0)
		End
	Else
		Begin
			SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0)
		End 
Else  
Begin  
 SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)  
End  
SET @PurchaseValue=IsNull(@PurchaseValue,0)  

--GST_Changes starts here
If ((Select isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'GSTaxEnabled' ) = 1)
Begin
	--Value for Branch Account
	Select @Netvalue = IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0)
	--Value for TaxonStocktransfer Account
	SET @TaxAmount = 0
	--Value for PurchaseTax or VAT_Receivable Account
	SET	@nVatTaxamount = 0
End
--GST_Changes ends here 

If IsNull(@NetValue,0) >0  
Begin  
 If @NetValue<>0  
 Begin  
  -- Entry for Branch Account  
  execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,@NetValue,0,@DocSerial,@AccountType,"Stock Transfer Out Amendment",@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)  
 End  
 If @PurchaseValue<>0  
 Begin  
  -- Entry for StockTransferOut Account  
  execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,0,@PurchaseValue,@DocSerial,@AccountType,"Stock Transfer Out Amendment",@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)  
 End  
 If @TaxAmount<>0  
 Begin  
  -- Entry for TaxonStocktransfer Account  
  execute sp_acc_insertGJ @TransactionID,@AccountID2,@DocumentDate,0,@TaxAmount,@DocSerial,@AccountType,"Stock Transfer Out Amendment",@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)   
 End  
 If @Vat_Exists = 1  
 Begin  
   if @nVatTaxamount <> 0    
   begin    
     -- Entry for VAT Tax Account     
	If @FLSTTaxType in(3,4) 
		Begin
			If (Round(Isnull(@nVatTaxamount,0),6)) -  Round(isnull(@FLSTTax,0),6) <> 0
			Begin   
				Set @nVatTaxamount = Isnull((Round(Isnull(@nVatTaxamount,0),6) -  Round(isnull(@FLSTTax,0),6)),0)
			   execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@DocumentDate,0,@nVatTaxamount,@DocSerial,@AccountType,"Stock Transfer Out Amendment",@DocumentNumber  
			   Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)   
			End
		End
	Else
		Begin
		   execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@DocumentDate,0,@nVatTaxamount,@DocSerial,@AccountType,"Stock Transfer Out Amendment",@DocumentNumber  
		   Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)   
		End 
  end  
 End  
End  
  
--Reversing the original invoice for amendment (amenmend entries)  
Set @FLSTTaxType = 1
If @Vat_Exists  = 1  
Begin  
 Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),  
 @TaxAmount=IsNull(TaxAmount,0) - isnull(VATTaxAmount,0),@BranchID=WareHouseID ,  
 @nVatTaxamount = isnull(VATTaxAmount,0)
 from StockTransferOutAbstract where DocSerial=@Reference
 
select @FLSTTax = Sum(Isnull(STO.TaxAmount,0))
from StockTransferOutdetail STO ,Batch_products B
Where STO.Batch_Code = B.Batch_Code 
And STO.DocSerial = @Reference And B.TaxType In(3,4)

If Isnull(@FLSTTax,0) <> 0 
	Begin
		set @FLSTTaxType = 3 -- FLST/FMRP (3 or 4)
	End 
End    
Else  
Begin  
 Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),  
 @TaxAmount=IsNull(TaxAmount,0),@BranchID=WareHouseID   
 from StockTransferOutAbstract where DocSerial=@Reference  
End  
-- Get AccountID of the branch from Branch master  
Select @AccountID=isnull(AccountID,0) from WareHouse where WareHouseID=@BranchID  
  
begin tran  
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24  
 Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24  
Commit Tran  
begin tran  
 update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51  
 Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51  
Commit Tran  
  
If @Vat_Exists  = 1  
Begin  
	If @FLSTTaxType in(3,4)
		Begin
			SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0)  + isnull(@FLSTTax,0)
		End
	Else
		Begin
			SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0)  
		End 
End  
Else  
Begin  
 SET @PurchaseValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)  
End  
SET @PurchaseValue=IsNull(@PurchaseValue,0)

--GST_Changes starts here
if ((select isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'GSTaxEnabled' ) = 1)
begin
	--Branch Account
	select @Netvalue = IsNull(@NetValue,0)-IsNull(@TaxAmount,0) - isnull(@nVatTaxamount,0)

	--TaxonStocktransfer Account
	select @TaxAmount = 0
end
--GST_Changes ends here  
  
If @NetValue >0  
Begin 
 If @PurchaseValue<>0  
 Begin  
  -- Entry for StockTransferOut Account
  execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@PurchaseValue,0,@Reference,@AccountType,"Stock Transfer Out Amended",@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)  
 End  

 If @TaxAmount<>0  
 Begin  
   --Entry for TaxonStocktransfer Account 
	execute sp_acc_insertGJ @TransactionID,@AccountID2,@DocumentDate,@TaxAmount,0,@Reference,@AccountType,"Stock Transfer Out Amended",@DocumentNumber  
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)  
 End  
 If @Vat_Exists = 1  
 Begin  
   if @nVatTaxamount <> 0    
   begin    
	  If @FLSTTaxType in(3,4)
		Begin
			Set @nVatTaxamount = Isnull(@nVatTaxamount,0) - Isnull(@FLSTTax,0)
		End

		If isnull(@nVatTaxamount,0) <> 0
			Begin
				execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@DocumentDate,@nVatTaxamount,0,@Reference,@AccountType,"Stock Transfer Out Amended",@DocumentNumber  
				Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)     
			End
  end  
 End  
 If @NetValue<>0  
 Begin  
   --Entry for Branch Account  
  execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@NetValue,@Reference,@AccountType,"Stock Transfer Out Amended",@DocumentNumber  
  Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)  
 End  
End  
  
--/*Backdated Operation */  
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
