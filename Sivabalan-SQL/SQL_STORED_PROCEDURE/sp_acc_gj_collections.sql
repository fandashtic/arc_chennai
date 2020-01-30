CREATE Procedure sp_acc_gj_collections (@DOCUMENTID INT,@BackDate DATETIME=Null)
AS
--Journal entry for collections
Declare @DocumentDate datetime
Declare @Value float
Declare @CustomerID nvarchar(15)
Declare @PaymentMode int
Declare @AccountID int
Declare @TransactionID int
Declare @DocumentNumber Int
Declare @OthersID Int
Declare @ExpenseID Int
Declare @Customer_Service_Charge float
Declare @BankAccountID Int
Declare @Adjustment float
Declare @ExtraAmount float

Declare @AccountID1 int
Declare @AccountID4 int
Declare @AccountID5 int
Declare @AccountID6 int
DECLARE @CREDITCARD_ACCOUNT Int
DECLARE @CREDITCARD_SERVICECHARGE_ACCOUNT Int
DECLARE @COUPON_ACCOUNT Int
DECLARE @COUPON_SERVICECHARGE_ACCOUNT Int

Set @AccountID1 = 3  --Cash Account
Set @AccountID4 = 7  --Cheque on Hand
Set @AccountID6 = 13 --Discount
Set @AccountID5 = 14 --Other Charges
SET @CREDITCARD_ACCOUNT = 94 -- Credit Card Account
SET @CREDITCARD_SERVICECHARGE_ACCOUNT = 103 -- Credit Card Service Charge Account
SET @COUPON_ACCOUNT = 95 -- COUPON Account
SET @COUPON_SERVICECHARGE_ACCOUNT = 104 -- COUPON Service Charge Account

Declare @AccountType Int
Set @AccountType =13

Declare @CASH INT
Declare @CHEQUE INT
Declare @DD INT
Declare @CREDITCARD INT
Declare @BANK_TRANSFER INT
Declare @COUPON INT

Set @CASH=0
Set @Cheque=1
Set @DD=2
Set @CREDITCARD = 3
Set @BANK_TRANSFER = 4
Set @COUPON = 5

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

Select @DocumentDate=DocumentDate, @Value=Value, @PaymentMode=PaymentMode,
@CustomerID=CustomerID,@OthersID=Others,@ExpenseID=ExpenseAccount from Collections 
where DocumentID=@DOCUMENTID

If @CustomerID is not null
Begin 
	if @CustomerID = N'GIFT VOUCHER'
	Begin
		Set @AccountID = 114
	End
	Else
	Begin
		Select @AccountID=AccountID from Customer where CustomerID=@CustomerID
	End

	If @Value <>0
	Begin
		-- Get the last TransactionID from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
			Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
		Commit Tran
		-- Get the last DocumentNumber from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
			Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
		Commit Tran

		If @PaymentMode=@CASH
		Begin
			-- Entry for Cash Account
			execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
		End
		Else if (@PaymentMode=@CHEQUE or @PaymentMode=@DD)
		Begin
			-- Entry for Cheque on Hand Account
			execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
		End
		Else If @PaymentMode=@CREDITCARD
		Begin
			Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
			SET @Value = @Value + @Customer_Service_Charge

			Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_ACCOUNT)    

			Execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID) 

			If @Customer_Service_Charge <> 0    
			Begin    
				Begin Tran    
					Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
					Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
				Commit Tran    
				Begin Tran    
					Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
					Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
				Commit Tran    

				Execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)    

				Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_SERVICECHARGE_ACCOUNT)    
			End       
		End
		Else If @PaymentMode=@BANK_TRANSFER
		Begin
			Select @BankAccountID = AccountID from Bank Where BankID = (Select BankID from Collections Where DocumentID = @DOCUMENTID)
		
			Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
			Execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
		
			Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)
		End
		Else If @PaymentMode=@COUPON
		Begin
			Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
			SET @Value = @Value + @Customer_Service_Charge

			Execute sp_acc_insertGJ @TransactionID,@COUPON_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_ACCOUNT)    

			Execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)    

			If @Customer_Service_Charge <> 0    
			Begin    
				Begin Tran    
					Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
					Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
				Commit Tran    
				Begin Tran    
					Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
					Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
				Commit Tran    

				Execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)    

				Execute sp_acc_insertGJ @TransactionID,@COUPON_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_SERVICECHARGE_ACCOUNT)    
			End    
		End
	End
	--Fetch ExtraAmount and Adjustment from collection table of  the passed DocumentID
	Select @ExtraAmount=sum(ExtraCollection),@Adjustment=Sum(abs(Adjustment)) from CollectionDetail where CollectionID=@DocumentID
	
	--If Adjustment then create journal for DiscountAccount else Othercharges Account
	If @Adjustment<>0
	Begin
		-- Get the last TransactionID from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
			Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
		Commit Tran
		-- Get the last DocumentNumber from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
			Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
		Commit Tran

		-- Entry for Discount Account
		execute sp_acc_insertGJ @TransactionID,@AccountID6,@DocumentDate,@Adjustment,0,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
		-- Entry for Customer Account
		execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@Adjustment,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)	
	End
	
	If @ExtraAmount<>0 
	Begin
		-- Get the last TransactionID from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
			Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
		Commit Tran
		-- Get the last DocumentNumber from the DocumentNumbers table
		begin tran
			update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
			Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
		Commit Tran

		-- Entry for Customer Account
		execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,@ExtraAmount,0,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
		-- Entry for Other Charges Account
		execute sp_acc_insertGJ @TransactionID,@AccountID5,@DocumentDate,0,@ExtraAmount,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID)	
		Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)	
	End
End
Else
Begin
	If isnull(@othersID,0) <> 0 and isnull(@ExpenseID,0) = 0
	Begin
		If @Value <>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			If @PaymentMode=@CASH
			Begin
				-- Entry for Cash Account
				execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
			Else if (@PaymentMode=@CHEQUE or @PaymentMode=@DD)
			Begin
				-- Entry for Cheque on Hand Account
				execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
			Else If @PaymentMode=@CREDITCARD
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
					Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_SERVICECHARGE_ACCOUNT)    
				End    
			End
			Else If @PaymentMode=@COUPON
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@COUPON_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
					Execute sp_acc_insertGJ @TransactionID,@COUPON_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_SERVICECHARGE_ACCOUNT)    
				End    
			End
			Else If @PaymentMode=@BANK_TRANSFER
			Begin
				Select @BankAccountID = AccountID from Bank Where BankID = (Select BankID from Collections Where DocumentID = @DOCUMENTID)
			
				Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
			
				Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
		End
		--Fetch ExtraAmount and Adjustment from collection table of  the passed DocumentID
		Select @ExtraAmount=sum(ExtraCollection),@Adjustment=Sum(abs(Adjustment)) from CollectionDetail where CollectionID=@DocumentID
		
		--If Adjustment then create journal for DiscountAccount else Othercharges Account
		If @Adjustment<>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Discount Account
			execute sp_acc_insertGJ @TransactionID,@AccountID6,@DocumentDate,@Adjustment,0,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Adjustment,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)		
		End
		
		If @ExtraAmount<>0 
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@ExtraAmount,0,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			-- Entry for Other Charges Account
			execute sp_acc_insertGJ @TransactionID,@AccountID5,@DocumentDate,0,@ExtraAmount,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)		
		End
	End
	Else If isnull(@OthersID,0) <> 0 and isnull(@ExpenseID,0) <> 0
	Begin
		If @Value <>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Cash Account
			execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
			-- Entry for Other Account
			execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)
		End
		If @Value <>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			If @PaymentMode=@CASH
			Begin
				-- Entry for Cash Account
				execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
			Else if (@PaymentMode=@CHEQUE or @PaymentMode=@DD)
			Begin
				-- Entry for Cheque on Hand Account
				execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
			Else If @PaymentMode=@CREDITCARD
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    

				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
					Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_SERVICECHARGE_ACCOUNT)    
				End    
			End
			Else If @PaymentMode=@BANK_TRANSFER
			Begin
				Select @BankAccountID = AccountID from Bank Where BankID = (Select BankID from Collections Where DocumentID = @DOCUMENTID)
			
				Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
			
				Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			End
			Else If @PaymentMode=@COUPON
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@COUPON_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    

				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)    
	
					Execute sp_acc_insertGJ @TransactionID,@COUPON_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_SERVICECHARGE_ACCOUNT)    
				End    
			End
		End
		--Fetch ExtraAmount and Adjustment from collection table of  the passed DocumentID
		Select @ExtraAmount=sum(ExtraCollection),@Adjustment=Sum(abs(Adjustment)) from CollectionDetail where CollectionID=@DocumentID
		
		--If Adjustment then create journal for DiscountAccount else Othercharges Account
		If @Adjustment<>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Discount Account
			execute sp_acc_insertGJ @TransactionID,@AccountID6,@DocumentDate,@Adjustment,0,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,0,@Adjustment,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)		
		End
		
		If @ExtraAmount<>0 
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@OthersID,@DocumentDate,@ExtraAmount,0,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			-- Entry for Other Charges Account
			execute sp_acc_insertGJ @TransactionID,@AccountID5,@DocumentDate,0,@ExtraAmount,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@OthersID)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)		
		End
	End 
	Else If isnull(@OthersID,0) = 0 and isnull(@ExpenseID,0) <> 0
	Begin
		If @Value <>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			If @PaymentMode=@CASH
			Begin
				-- Entry for Cash Account
				execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cash",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID1)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)
			End
			Else if (@PaymentMode=@CHEQUE or @PaymentMode=@DD)
			Begin
				-- Entry for Cheque on Hand Account
				execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				-- Entry for Other Account
				execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,"Collection of Cheque/DD",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID4)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)
			End
			Else If @PaymentMode=@CREDITCARD
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Credit Card Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)    

				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)    
	
					Execute sp_acc_insertGJ @TransactionID,@CREDITCARD_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Credit Card Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@CREDITCARD_SERVICECHARGE_ACCOUNT)    
				End    
			End
			Else If @PaymentMode=@BANK_TRANSFER
			Begin
				Select @BankAccountID = AccountID from Bank Where BankID = (Select BankID from Collections Where DocumentID = @DOCUMENTID)
			
				Execute sp_acc_insertGJ @TransactionID,@BankAccountID,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
				Execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Collection - Bank Transfer',@DocumentNumber
			
				Insert Into #TempBackdatedAccounts(AccountID) Values(@BankAccountID)
				Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)
			End
			Else If @PaymentMode=@COUPON
			Begin
				Select @Customer_Service_Charge = IsNull(CustomerServiceCharge,0) from Collections Where DocumentID = @DOCUMENTID    
				SET @Value = @Value + @Customer_Service_Charge
	
				Execute sp_acc_insertGJ @TransactionID,@COUPON_ACCOUNT,@DocumentDate,@Value,0,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_ACCOUNT)    
	
				Execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Value,@DocumentID,@AccountType,'Coupon Collection',@DocumentNumber    
				Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)    

				If @Customer_Service_Charge <> 0    
				Begin    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=24    
						Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24    
					Commit Tran    
					Begin Tran    
						Update DocumentNumbers SET DocumentID=DocumentID+1 where DocType=51    
						Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51    
					Commit Tran    
	
					Execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,@Customer_Service_Charge,0,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)    
	
					Execute sp_acc_insertGJ @TransactionID,@COUPON_SERVICECHARGE_ACCOUNT,@DocumentDate,0,@Customer_Service_Charge,@DocumentID,@AccountType,'Coupon Collection - Service Charge',@DocumentNumber    
					Insert Into #TempBackdatedAccounts(AccountID) Values(@COUPON_SERVICECHARGE_ACCOUNT)    
				End    
			End
		End
		--Fetch ExtraAmount and Adjustment from collection table of  the passed DocumentID
		Select @ExtraAmount=sum(ExtraCollection),@Adjustment=Sum(abs(Adjustment)) from CollectionDetail where CollectionID=@DocumentID
		
		--If Adjustment then create journal for DiscountAccount else Othercharges Account
		If @Adjustment<>0
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Discount Account
			execute sp_acc_insertGJ @TransactionID,@AccountID6,@DocumentDate,@Adjustment,0,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,0,@Adjustment,@DocumentID,@AccountType,'Adjusted with Shortage Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID6)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)		
		End
		
		If @ExtraAmount<>0 
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran
			-- Get the last DocumentNumber from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
				Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
			Commit Tran
	
			-- Entry for Customer Account
			execute sp_acc_insertGJ @TransactionID,@ExpenseID,@DocumentDate,@ExtraAmount,0,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			-- Entry for Other Charges Account
			execute sp_acc_insertGJ @TransactionID,@AccountID5,@DocumentDate,0,@ExtraAmount,@DocumentID,@AccountType,'Extra Amount Collected',@DocumentNumber
			Insert Into #TempBackdatedAccounts(AccountID) Values(@ExpenseID)
			Insert Into #TempBackdatedAccounts(AccountID) Values(@AccountID5)		
		End
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

/*
Begin
	If @Value <>0
	Begin
		If @PaymentMode=@CASH
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran

			-- Entry for Cash Account
			execute sp_acc_insertGJ @TransactionID,@AccountID1,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cash"
		End
		Else if (@PaymentMode=@CHEQUE or @PaymentMode=@DD)
		Begin
			-- Get the last TransactionID from the DocumentNumbers table
			begin tran
				update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
				Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
			Commit Tran

			-- Entry for Cheque on Hand Account
			execute sp_acc_insertGJ @TransactionID,@AccountID4,@DocumentDate,@Value,0,@DocumentID,@AccountType,"Collection of Cheque/DD"
		End
	End

	Declare @AdjustedAmount Decimal(18,6)
	DECLARE scancollectiondetail CURSOR KEYSET FOR
	Select AdjustedAmount,Others from CollectionDetail where CollectionID=@DOCUMENTID
	OPEN scancollectiondetail
	FETCH FROM scancollectiondetail INTO @AdjustedAmount,@AccountID
	While @@FETCH_STATUS=0
	Begin
		If @AdjustedAmount<>0
		Begin
			-- Entry for Other Accounts 
			If @PaymentMode=@CASH
			Begin
				execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@AdjustedAmount,@DocumentID,@AccountType,"Collection of Cash"
			End
			Else
			Begin
				execute sp_acc_insertGJ @TransactionID,@AccountID,@DocumentDate,0,@AdjustedAmount,@DocumentID,@AccountType,"Collection of Cheque/DD"
			End
		End
		FETCH NEXT FROM scancollectiondetail INTO @AdjustedAmount,@AccountID
	End
	CLOSE scancollectiondetail
	DEALLOCATE scancollectiondetail
 End
*/
