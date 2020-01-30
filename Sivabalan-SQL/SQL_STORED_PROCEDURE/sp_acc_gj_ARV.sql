CREATE Procedure sp_acc_gj_ARV (@DocumentID INT,@BackDate DATETIME=Null)
AS
--Journal entry for Retail Invoice
Declare @ARVDate datetime
Declare @NetValue float
Declare @Amount float
Declare @TotalSalesTax float
Declare @TransactionID int
Declare @DocumentNumber int
Declare @AccountID1 int
Declare @AccountID2 int
Declare @SaleableAssetValue Decimal(18,6),@DiffSaleAssetValue Decimal(18,6),@Particular nVarchar(4000)
Declare @AccountType Int
Declare @Type Int
Declare @PROFITONSALEOFASSET Int
Declare @LOSSONSALEOFASSET Int
Declare @SALESTAXACCOUNT Int
Set @AccountType =48
Set @PROFITONSALEOFASSET =90
Set @LOSSONSALEOFASSET=91
Set @SALESTAXACCOUNT=1

Declare @TempTransactionID Int
Declare @TempDocumentNumber Int

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

Select @ARVDate=ARVDate,@AccountID1=PartyAccountID, @NetValue=Amount,@TotalSalesTax=IsNull(TotalSalesTax,0) from ARVAbstract where DocumentID=@DocumentID
-- Get the last TransactionID from the DocumentNumbers table
begin tran
	update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
	Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
Commit Tran
begin tran
	update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
	Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
Commit Tran

If @NetValue<>0
Begin
	Set @TempTransactionID=@TransactionID -- To have same transaction id for all credit entries
	Set @TempDocumentNumber=@DocumentNumber
	-- Entry for Party Account
	execute sp_acc_insertGJ @TransactionID,@AccountID1,@ARVDate,@NetValue,0,@DocumentID,@AccountType,"ARV",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
End

DECLARE scanarvdetail CURSOR KEYSET FOR
Select AccountID,Type,Amount,Particular from ARVDetail where DocumentID=@DocumentID
OPEN scanarvdetail
FETCH FROM scanarvdetail INTO @AccountID2,@Type,@Amount,@Particular
While @@FETCH_STATUS = 0
Begin

	If @Amount<>0
	Begin
		If @Type=0
		Begin
			-- Entry for Asset Account	
			execute sp_acc_insertGJ @TempTransactionID,@AccountID2,@ARVDate,0,@Amount,@DocumentID,@AccountType,"ARV",@TempDocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
	
			Set @SaleableAssetValue=0
			Set @DiffSaleAssetValue=0
			--Procedure to get the Purchese value sold assets
			Execute sp_acc_getpurchasevalueofarvassets @Particular,@SaleableAssetValue Output
			--Set @SaleableAssetValue=isnull(dbo.sp_acc_getsaleableassetvalue(@AccountID2),0)
			
			Set @DiffSaleAssetValue=@Amount-@SaleableAssetValue
			--Select @Amount,@SaleableAssetValue,@DiffSaleAssetValue
			If @DiffSaleAssetValue>0 --Profit
			Begin
				begin tran
					update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
					Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
				Commit Tran
				begin tran
					update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
					Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
				Commit Tran

				-- Entry for Asset Account
				execute sp_acc_insertGJ @TransactionID,@AccountID2,@ARVDate,@DiffSaleAssetValue,0,@DocumentID,@AccountType,"ARV-Profit",@DocumentNumber
				-- Entry for Profit on Sale of Asset Account
				execute sp_acc_insertGJ @TransactionID,@PROFITONSALEOFASSET,@ARVDate,0,@DiffSaleAssetValue,@DocumentID,@AccountType,"ARV-Profit",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)	
				Insert Into #TempBackdatedAccounts(AccountID) Values(@PROFITONSALEOFASSET)	
			End
			Else If @DiffSaleAssetValue<0 --Loss
			Begin
				begin tran
					update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
					Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
				Commit Tran
				begin tran
					update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
					Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
				Commit Tran

				Set @DiffSaleAssetValue=Abs(@DiffSaleAssetValue) 
				-- Entry for Loss on Sale of Asset Account
				execute sp_acc_insertGJ @TransactionID,@LOSSONSALEOFASSET,@ARVDate,@DiffSaleAssetValue,0,@DocumentID,@AccountType,"ARV-Loss",@DocumentNumber
				-- Entry for Asset Account				
				execute sp_acc_insertGJ @TransactionID,@AccountID2,@ARVDate,0,@DiffSaleAssetValue,@DocumentID,@AccountType,"ARV-Loss",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)	
				Insert Into #TempBackdatedAccounts(AccountID) Values(@LOSSONSALEOFASSET)	
			End
		End
		Else
		Begin
			-- Entry for other than Asset Account
			execute sp_acc_insertGJ @TempTransactionID,@AccountID2,@ARVDate,0,@Amount,@DocumentID,@AccountType,"ARV",@TempDocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)	
		End
	End

	FETCH NEXT FROM scanarvdetail INTO @AccountID2,@Type,@Amount,@Particular
End
CLOSE scanarvdetail
DEALLOCATE scanarvdetail

If @TotalSalesTax<>0
Begin
	-- Entry for SalesTax Account
	execute sp_acc_insertGJ @TempTransactionID,@SALESTAXACCOUNT,@ARVDate,0,@TotalSalesTax,@DocumentID,@AccountType,"ARV",@TempDocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@SALESTAXACCOUNT)
End

-------------------------------Service Charge implementation----------------------------
-- Get the last TransactionID from the DocumentNumbers table
begin tran
	update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
	Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
Commit Tran
begin tran
	update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
	Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
Commit Tran

Declare @SumServiceChargeAmt Decimal(18,6)
DECLARE scanarvdetailsc CURSOR KEYSET FOR
Select Type,ServiceChargeAmount from ARVDetail where DocumentID=@DocumentID
OPEN scanarvdetailsc
FETCH FROM scanarvdetailsc INTO @Type,@Amount
While @@FETCH_STATUS = 0
Begin
	If @Amount<>0
	Begin
		Set @SumServiceChargeAmt=IsNull(@SumServiceChargeAmt,0) + IsNull(@Amount,0)
		If @Type=3 --CreditCard
		Begin
			Set @AccountID2=103 --Fixed Credit Card Service Charge Account
			-- Entry for Asset Account	
			execute sp_acc_insertGJ @TransactionID,@AccountID2,@ARVDate,@Amount,0,@DocumentID,@AccountType,"ARV-Service Charge",@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
		End
		Else If @Type=4 --Coupon
		Begin
			Set @AccountID2=104 --Fixed Coupon Service Charge Account
			-- Entry for Asset Account	
			execute sp_acc_insertGJ @TransactionID,@AccountID2,@ARVDate,@Amount,0,@DocumentID,@AccountType,"ARV-ServiceCharge",@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID2)
		End
	End
	FETCH NEXT FROM scanarvdetailsc INTO @Type,@Amount
End
CLOSE scanarvdetailsc
DEALLOCATE scanarvdetailsc

If @SumServiceChargeAmt<>0
Begin
	-- Entry for SalesTax Account
	execute sp_acc_insertGJ @TransactionID,@AccountID1,@ARVDate,0,@SumServiceChargeAmt,@DocumentID,@AccountType,"ARV-ServiceCharge",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
	Update ARVAbstract Set Balance=IsNull(Balance,0)-IsNull(@SumServiceChargeAmt,0) Where DocumentID=@DocumentID --service charge internally deduct from balance
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

