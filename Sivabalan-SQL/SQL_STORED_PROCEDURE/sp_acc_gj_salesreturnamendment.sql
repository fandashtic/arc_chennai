CREATE Procedure sp_acc_gj_salesreturnamendment (@INVOICEID INT,@BackDate DATETIME=Null)
AS
--Journal entries for Sales Return Amendment

Declare @InvoiceDate datetime
Declare @NetValue decimal(18,6)
Declare @TaxAmount decimal(18,6)
Declare @TotalSalesTax decimal(18,6)
Declare @TotalTaxSuffered decimal(18,6)
Declare @AccountID int
Declare @CustomerID nvarchar(15)
Declare @Status Int
Declare @TransactionID int
Declare @DocumentNumber Int
Declare @Freight Decimal(18,6)
Declare @InvReference Int

Declare @AccountID1 int
Declare @AccountID2 int
Declare @AccountID3 int
Declare @AccountID4 int
Declare @AccountID5 int
Declare @AccountID6 int
Set @AccountID1 = 3  --Cash Account
Set @AccountID2 = 1  --SalesTax Account
--Set @AccountID3 = 30  --Sales Return - Saleable
Set @AccountID4 = 7  --Cheque on Hand
Set @AccountID5 = 29 --Tax Suffered Account
Set @AccountID6 = 33 --Freight Account

Declare @AccountType Int
Set @AccountType =72

Declare @Vat_Exists Integer
Declare @VAT_Payable Integer
Declare @nVatTaxamount decimal(18,6)
Set @VAT_Payable  = 116  /* Constant to store the VAT Payable (Output Tax) AccountID*/     
Set @Vat_Exists = 0 
If dbo.columnexists('InvoiceAbstract','VATTaxAmount') = 1
Begin
	Set @Vat_Exists = 1
end

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

If @Vat_Exists  = 1
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0) - isnull(VATTaxAmount,0),
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = Status,
	@Freight=isnull(Freight,0),@InvReference=isnull(InvoiceReference,0), 
	@nVatTaxamount = isnull(VATTaxAmount,0)
	from InvoiceAbstract where InvoiceID=@INVOICEID
End
Else
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0),
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = Status,
	@Freight=isnull(Freight,0),@InvReference=isnull(InvoiceReference,0) from InvoiceAbstract where InvoiceID=@INVOICEID
End
-- Tax Computation from InvoiceDetail table
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@INVOICEID
Set @TaxAmount=IsNull(@TotalSalesTax,0)+IsNull(@TotalTaxsuffered,0)
-- Get AccountID of the customer from Customer master
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID

If (isnull(@status,0) & 32)<>0
	Set @AccountID3 = 32  --Sales Return - Damage
Else
	Set @AccountID3 = 30  --Sales Return - Saleable

Declare @SalesValue float
If @Vat_Exists  = 1
Begin
	SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0) - @nVatTaxamount
End
Else
Begin
	SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0)
End
-- To get the new TransactionID for GJ entry
Begin Tran
	update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24
	Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
Commit Tran
-- To get the new DocumentNumber for GJ entry
Begin Tran
	update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51
	Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
Commit Tran

-- Procedure to insert journal entries for Sales Return in GJ table.
If @TotalSalesTax<>0
Begin
	-- Entry for Sales tax account
	Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
End
If @TotalTaxSuffered<>0
Begin
	-- Entry for Tax suffered account
	Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalSalesTax,0,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)
End
If @Vat_Exists = 1
Begin
	If @nVatTaxamount<>0
	Begin
		-- Entry for VAT
		Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,@nVatTaxamount,0,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)
	End
End

If @Freight<>0
Begin
	-- Entry for Sales tax account
	Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
End
If @SalesValue<>0
Begin
	-- Entry for Sales account
	Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)
End
If @NetValue<>0
Begin
	-- Entry for customer account
	Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@INVOICEID,@AccountType,"Sales Return Amendment",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
End

--Reverse entry for sales return amendment (amended journal entry)
If @Vat_Exists = 1
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0) - isnull(VATTaxAmount,0),
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = Status,
	@Freight=isnull(Freight,0) ,@nVatTaxamount = isnull(VATTaxAmount,0)
	from InvoiceAbstract where InvoiceID=@InvReference
End
Else
Begin
	Select @InvoiceDate=InvoiceDate, @NetValue=IsNull(NetValue,0),@TotalSalesTax=IsNull(TotalTaxApplicable,0),
	@TotalTaxSuffered=IsNull(TotalTaxSuffered,0), @CustomerID=CustomerID,@Status = Status,
	@Freight=isnull(Freight,0) from InvoiceAbstract where InvoiceID=@InvReference
End

-- Tax Computation from InvoiceDetail table
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@INVOICEID
Set @TaxAmount=IsNull(@TotalSalesTax,0)+IsNull(@TotalTaxsuffered,0)
-- Get AccountID of the customer from Customer master
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID

If (isnull(@status,0) & 32)<>0
	Set @AccountID3 = 32  --Sales Return - Damage
Else
	Set @AccountID3 = 30  --Sales Return - Saleable


If @Vat_Exists  = 1
Begin
	SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0) - isnull(@nVatTaxamount,0)
end
Else
Begin
	SET @SalesValue=IsNull(@NetValue,0)-IsNull(@TaxAmount,0)-IsNull(@Freight,0)
end
-- To get the new TransactionID for GJ entry
Begin Tran
	update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24
	Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
Commit Tran
-- To get the new DocumentNumber for GJ entry
Begin Tran
	update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51
	Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
Commit Tran

-- Procedure to insert journal entries for Sales Return in GJ table.
If @NetValue<>0
Begin
	-- Entry for customer account
	Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
End
If @TotalSalesTax<>0
Begin
	-- Entry for Sales tax account
	Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,0,@TotalSalesTax,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
End
If @TotalTaxSuffered<>0
Begin
	-- Entry for Tax suffered account
	Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,0,@TotalSalesTax,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)
End
If @Vat_Exists  = 1
Begin
	If @nVatTaxamount<>0
	Begin
		-- Entry for VAT
		Execute sp_acc_insertGJ @TransactionID,@VAT_Payable,@InvoiceDate,0,@nVatTaxamount,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@VAT_Payable)
	End
End

If @Freight<>0
Begin
	-- Entry for Sales tax account
	Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,0,@Freight,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
End
If @SalesValue<>0
Begin
	-- Entry for Sales account
	Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,0,@SalesValue,@InvReference,@AccountType,"Sales Return Amended",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID3)
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



