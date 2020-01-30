
CREATE Procedure sp_acc_gj_existinvoicecancel (@INVOICEID INT)
AS
--Journal entries for Invoice cancellation

Declare @InvoiceDate datetime
Declare @NetValue float
Declare @TaxAmount float
Declare @TotalSalesTax decimal(18,6)
Declare @TotalTaxSuffered decimal(18,6)
Declare @AccountID int
Declare @CustomerID nvarchar(15)
Declare @TransactionID int
Declare @PaymentMode int
Declare @DocumentNumber Int
Declare @Freight Decimal(18,6)
Declare @RoundOffAmount Decimal(18,6)
Declare @NetBalance Decimal(18,6)

Declare @AccountID1 int
Declare @AccountID2 int
Declare @AccountID3 int
Declare @AccountID4 int
Declare @AccountID5 int
Declare @AccountID6 int
Set @AccountID1 = 3  --Cash Account
Set @AccountID2 = 1  --SalesTax Account
Set @AccountID3 = 5  --Sales Account
Set @AccountID4 = 7  --Cheque on Hand
Set @AccountID5 = 29 --Tax Suffered Account
Set @AccountID6 = 33 --Freight Account

Declare @AccountType Int,@CollectionCancelType Int
Set @AccountType =6
Set @CollectionCancelType=25

Declare @CASH int
Declare @CHEQUE int
Declare @CREDIT int
Declare @DD int
SET @CASH =1
SET @CHEQUE=2
SET @CREDIT=0
SET @DD=3

Declare @paymentDetails Int 

Select @InvoiceDate=InvoiceDate, @NetValue=NetValue,@TotalSalesTax=TotalTaxApplicable,
@TotalTaxSuffered=TotalTaxSuffered, @CustomerID=CustomerID,@PaymentMode=PaymentMode,
@Freight=isnull(Freight,0),@RoundOffAmount=isnull(RoundOffAmount,0) from InvoiceAbstract where InvoiceID=@INVOICEID

-- Tax Computation from InvoiceDetail table
--Select @TaxAmount=Sum((isnull(STPayable,0)+isnull(CSTPayable,0))+((isnull(SalePrice,0)*isnull(Quantity,0))*(isnull(TaxSuffered,0)/100))) from InvoiceDetail where InvoiceID=@INVOICEID
Set @TaxAmount=@TotalSalesTax+@TotalTaxsuffered
-- Get AccountID of the customer from Customer master
Select @AccountID=AccountID from Customer where CustomerID=@CustomerID

Declare @SalesValue float
SET @SalesValue=@NetValue-@TaxAmount-@Freight

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

If @PaymentMode = @CREDIT
Begin
	-- Procedure to insert journal entries for Invoice cancelation in GJ table.
	If @TotalSalesTax<>0
	Begin
		-- Entry for Sales tax account
		Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@INVOICEID,@AccountType,"Credit Invoice Cancellation",@DocumentNumber
	End
	If @TotalTaxSuffered<>0
	Begin
		-- Entry for Tax suffered account
		Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@INVOICEID,@AccountType,"Credit Invoice Cancellation",@DocumentNumber
	End
	If @Freight<>0
	Begin
		-- Entry for Freight account
		Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@INVOICEID,@AccountType,"Credit Invoice Cancellation",@DocumentNumber
	End
	If @SalesValue<>0
	Begin
		-- Entry for Sales account
		Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@INVOICEID,@AccountType,"Credit Invoice Cancellation",@DocumentNumber
	End
	If @NetValue<>0
	Begin
		-- Entry for customer account
		Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@INVOICEID,@AccountType,"Credit Invoice Cancellation",@DocumentNumber
	End
End
Else if @PaymentMode = @CASH
Begin
	-- Procedure to insert journal entries for Invoice cancellation 1st set in GJ table.
	If @TotalSalesTax<>0
	Begin
		-- Entry for Debit Sales tax Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@INVOICEID,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
	End
	If @TotalTaxSuffered<>0
	Begin
		-- Entry for Debit Tax suffered Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@INVOICEID,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
	End
	If @Freight<>0
	Begin
		-- Entry for Debit Freight Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@INVOICEID,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
	End
	If @SalesValue<>0
	Begin
		-- Entry for Debit Sales Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@INVOICEID,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
	End
	If @NetValue<>0
	Begin
		-- Entry for Credit customer Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@INVOICEID,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
	End
	
-- 	SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)
-- 	IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)
-- 	Begin
-- 		-- Procedure to insert journal entries for Invoice cancellation 2nd set in GJ table.
-- 		-- To get the new TransactionID for GJ entry
-- 		Begin Tran
-- 			update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24
-- 			Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
-- 		Commit Tran
-- 		-- To get the new DocumentNumber for GJ entry
-- 		Begin Tran
-- 			update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51
-- 			Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
-- 		Commit Tran
-- 
-- 		If @RoundOffAmount <> 0
-- 		Begin
-- 			Set @NetBalance=@NetValue + @RoundOffAmount
-- 		End
-- 		Else 
-- 		Begin
-- 			Set @NetBalance=@NetValue
-- 		End		
-- 
-- 		If @NetValue<>0
-- 		Begin
-- 			-- Entry for Debit Customer Account
-- 			Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetBalance,0,@PaymentDetails,@CollectionCancelType,"Cash Invoice Cancellation",@DocumentNumber
-- 			-- Entry for Credit Cash Account
-- 			Execute sp_acc_insertGJ @TransactionID,@AccountID1,@InvoiceDate,0,@NetBalance,@PaymentDetails,@AccountType,"Cash Invoice Cancellation",@DocumentNumber
-- 		End
-- 	End
End
Else if (@PaymentMode = @CHEQUE) or (@PaymentMode = @DD)
Begin
	-- Procedure to insert journal entries for Invoice cancellation 1st set in GJ table.
	If @TotalSalesTax<>0
	Begin
		-- Entry for Debit Sales tax Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID2,@InvoiceDate,@TotalSalesTax,0,@INVOICEID,@AccountType,"Cheque/DD Invoice Cancellation",@DocumentNumber
	End
	If @TotalTaxSuffered<>0
	Begin
		-- Entry for Debit Tax suffered Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID5,@InvoiceDate,@TotalTaxSuffered,0,@INVOICEID,@AccountType,"Cheque/DD Invoice Cancellation",@DocumentNumber
	End
	If @Freight<>0
	Begin
		-- Entry for Debit Freight Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID6,@InvoiceDate,@Freight,0,@INVOICEID,@AccountType,"Cheque/DD Invoice Cancellation",@DocumentNumber
	End
	If @Salesvalue<>0
	Begin
		-- Entry for Debit Sales Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID3,@InvoiceDate,@SalesValue,0,@INVOICEID,@AccountType,"Cheque/DD Invoice Cancellation",@DocumentNumber
	End
	If @NetValue<>0
	Begin
		-- Entry for Credit customer Account
		Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@NetValue,@INVOICEID,@AccountType,"Cheque/DD Invoice Cancellation",@DocumentNumber
	End

-- 	SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVOICEID) as int)
-- 	IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)
-- 	Begin
-- 		-- Procedure to insert journal entries for Invoice cancellation 2nd set in GJ table.
-- 		-- To get the new TransactionID for GJ entry
-- 		Begin Tran
-- 			update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=24
-- 			Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
-- 		Commit Tran
-- 		-- To get the new DocumentNumber for GJ entry
-- 		Begin Tran
-- 			update DocumentNumbers Set DocumentID=DocumentID+1 where DocType=51
-- 			Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
-- 		Commit Tran
-- 
-- 		If @RoundOffAmount <> 0
-- 		Begin
-- 			Set @NetBalance=@NetValue + @RoundOffAmount
-- 		End
-- 		Else 
-- 		Begin
-- 			Set @NetBalance=@NetValue
-- 		End		
-- 
-- 		If @NetValue<>0
-- 		Begin
-- 			-- Entry for Debit Customer Account
-- 			Execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetBalance,0,@PaymentDetails,@CollectionCancelType,"Cheque/DD Invoice Cancellation",@DocumentNumber
-- 			-- Entry for Credit Cheque on Hand Account
-- 			Execute sp_acc_insertGJ @TransactionID,@AccountID4,@InvoiceDate,0,@NetBalance,@PaymentDetails,@CollectionCancelType,"Cheque/DD Invoice Cancellation",@DocumentNumber
-- 		End
-- 	End
End

--
Declare @RoundOffAccount Int
Set @RoundOffAccount=92

If @RoundOffAmount >0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	-- Entry for RoundOff Account
	execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber
	-- Entry for Customer Account
	execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber

End
Else If @RoundOffAmount <0
Begin
	Set @RoundOffAmount=Abs(@RoundOffAmount)
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	-- Entry for Customer Account
	execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@RoundOffAmount,0,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber
	-- Entry for RoundOff Account
	execute sp_acc_insertGJ @TransactionID,@RoundOffAccount,@InvoiceDate,0,@RoundOffAmount,@InvoiceID,@AccountType,"Invoice - RoundOff Amount",@DocumentNumber
End

--

Declare @SecSchemeValue Decimal(18,6)
Declare @SecondarySchemeExpense Int,@ClaimsRecivable Int
Set @SecondarySchemeExpense = 39
Set @ClaimsRecivable = 10

Select @SecSchemeValue=sum(isnull(Cost,0)) from SchemeSale where InvoiceId=@invoiceID
If @SecSchemeValue<>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	-- Entry for ClaimsRecivable Account
	execute sp_acc_insertGJ @TransactionID,@ClaimsRecivable,@InvoiceDate,@SecSchemeValue,0,@InvoiceID,@AccountType,"Secondary Scheme",@DocumentNumber
	-- Entry for SecondarySchemeExpense Account
	execute sp_acc_insertGJ @TransactionID,@SecondarySchemeExpense,@InvoiceDate,0,@SecSchemeValue,@InvoiceID,@AccountType,"Secondary Scheme",@DocumentNumber

End

-- Credit/Debit Note cancellation journal entries
Declare @ReferenceID Int,@Type Int
If exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @InvoiceID)
Begin
	DECLARE scanadjustmentreference CURSOR KEYSET FOR
	Select ReferenceID, DocumentType from AdjustmentReference where InvoiceID = @InvoiceID
	OPEN scanadjustmentreference
	FETCH FROM scanadjustmentreference INTO @ReferenceID,@Type
	WHILE @@FETCH_STATUS=0
	Begin
		If @Type=5 -- Debit Note
		Begin
			Exec sp_acc_gj_debitnoteCancel @ReferenceID
		End
		Else If @Type=2 -- Credit Note
		Begin
			Exec sp_acc_gj_creditnoteCancel @ReferenceID
		End
		FETCH NEXT FROM scanadjustmentreference INTO @ReferenceID,@Type
	End
	CLOSE scanadjustmentreference
	DEALLOCATE scanadjustmentreference
End






































