CREATE Procedure sp_acc_gj_stocktransferin (@DocSerial INT,@BackDate DATETIME=Null)
AS
--Journal entry for Retail Invoice
Declare @DocumentDate datetime
Declare @NetValue float
Declare @TaxAmount float
Declare @AccountID int
Declare @BranchID nvarchar(25)
Declare @TransactionID int
Declare @DocumentNumber int

Declare @AccountID1 int
Declare @AccountID2 int
Set @AccountID1 = 36  --StockTransferIn Account
Set @AccountID2 = 38  --Tax on StockTransfer Account

Declare @AccountType Int
Set @AccountType =54

Declare @Vat_Exists Integer
Declare @VAT_Receivable Integer
Declare @nVatTaxamount decimal(18,6)
--Tax Type LST/CST/FLST changes
Declare @TaxType Integer
Declare @FLSTTaxType Integer
Declare @FLSTNetValue decimal(18,6)
Declare @PurchaseTax Integer
set @PurchaseTax = 2

Set @VAT_Receivable  = 115  /* Constant to store the VAT Receivable (Input Tax Credit) AcountID*/     
Set @Vat_Exists = 0 
If dbo.columnexists('StockTransferInAbstract','VATTaxAmount') = 1
Begin
	Set @Vat_Exists = 1
end

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

If @Vat_Exists  = 1
Begin
	Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),
	@TaxAmount=IsNull(TaxAmount,0)-isnull(VATTaxAmount,0),@BranchID=WareHouseID, 
	@nVatTaxamount = isnull(VATTaxAmount,0),@FLSTNetValue = isnull(NetValue,0),
	@Taxtype = case isnull(TaxType,1) when 2 then TaxType else 1 end,
	@FLSTTaxType = isnull(TaxType,1)
	from StockTransferInAbstract where DocSerial=@DocSerial
End
Else
Begin
	Select @DocumentDate=DocumentDate, @NetValue=IsNull(NetValue,0),
	@TaxAmount=IsNull(TaxAmount,0),@BranchID=WareHouseID 
	from StockTransferInAbstract where DocSerial=@DocSerial
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
	If @PurchaseValue<>0
	Begin
		-- Entry for StockTransferIn Account
		If Isnull(@FLSTTaxType ,0) In (3,4)
			Begin
				Set @PurchaseValue = @FLSTNetValue
			End
		execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@PurchaseValue,0,@DocSerial,@AccountType,"Stock Transfer In",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
	End
	If @TaxAmount<>0
	Begin
		-- Entry for TaxonStocktransfer Account
		execute sp_acc_insertGJ @TransactionID,@AccountID2,@DocumentDate,@TaxAmount,0,@DocSerial,@AccountType,"Stock Transfer In",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
	End
	If @Vat_Exists = 1
	Begin
	 	if @nVatTaxamount <> 0  
	 	begin  
	  		-- Entry for VAT Tax Account     
			if @TaxType = 2
				Begin
					execute sp_acc_insertGJ @TransactionID,@PurchaseTax,@DocumentDate,@nVatTaxamount,0,@DocSerial,@AccountType,"Stock Transfer In",@DocumentNumber
					Insert Into #TempBackdatedAccounts(AccountID) Values(@PurchaseTax)
				end
			else
				Begin
					If Isnull(@FLSTTaxType ,0) Not In (3,4)
						Begin
							execute sp_acc_insertGJ @TransactionID,@VAT_Receivable,@DocumentDate,@nVatTaxamount,0,@DocSerial,@AccountType,"Stock Transfer In",@DocumentNumber
							Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Receivable)
						End
				end
		end
	End

	If @NetValue<>0
	Begin
		-- Entry for Branch Account
		execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@NetValue,@DocSerial,@AccountType,"Stock Transfer In",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
	End
End

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
