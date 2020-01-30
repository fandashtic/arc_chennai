CREATE Procedure sp_acc_gjexist_updateaccount
As

/*Creating an AccountID in AccountMaster table for each customer and 
 update the AccountId into the Customer table */
Declare @CustomerID nvarchar(15)
Declare @CustomerName nvarchar(128)
Declare @Active Int
DECLARE @DEBTORSGROUP INT
SET @DEBTORSGROUP=22

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'Masters'

Declare @UpgradeStatus Int
Select @UpgradeStatus=IsNull(Status,0) from FAUpgradeStatus Where ModuleName = @MODULENAME
If @UpgradeStatus=0
Begin

	Begin Tran
	
	DECLARE ScanCustomerMaster CURSOR KEYSET FOR
	Select CustomerID,Company_Name,Active from Customer where isnull(AccountID,0)=0
	Open ScanCustomerMaster
	FETCH FROM ScanCustomerMaster INTO @CustomerID,@CustomerName,@Active
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* Insertion of customer account into the AccountMaster table. */
		Execute sp_acc_insertaccountsforexistingmasters @CustomerName,@DEBTORSGROUP,@Active
		/* Updation of new AccounID into the Customer table. */	
		update customer set AccountID=@@Identity where customerID=@CustomerID
		FETCH NEXT FROM ScanCustomerMaster INTO @CustomerID,@CustomerName,@Active
	END
	CLOSE ScanCustomerMaster
	DEALLOCATE ScanCustomerMaster
	
	
	/*Creating an AccountID in AccountMaster table for each vendor and 
	 update the AccountId into the Vendor table */
	Declare @VendorID nvarchar(15)
	Declare @VendorName nvarchar(50)
	DECLARE @CREDITORSGROUP INT
	SET @CREDITORSGROUP=11
	
	DECLARE ScanVendorMaster CURSOR KEYSET FOR
	Select VendorID,Vendor_Name,Active from Vendors where isnull(AccountID,0)=0
	Open ScanVendorMaster
	FETCH FROM ScanVendorMaster INTO @VendorID,@VendorName,@Active
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Execute sp_acc_insertaccountsforexistingmasters @VendorName,@CREDITORSGROUP,@Active
		update Vendors set AccountID=@@Identity where VendorID=@VendorID
		FETCH NEXT FROM ScanVendorMaster INTO @VendorID,@VendorName,@Active
	END
	CLOSE ScanVendorMaster
	DEALLOCATE ScanVendorMaster
	
	/*Creating an AccountID in AccountMaster table for each AccountNumber and 
	 update the AccountID into the Bank table */
	Declare @AccountNumber nvarchar(64)
	DECLARE @BANKGROUP INT
	SET @BANKGROUP=18
	
	DECLARE ScanBankMaster CURSOR KEYSET FOR
	Select Account_Number,Active from Bank where isnull(AccountID,0)=0
	Open ScanBankMaster
	FETCH FROM ScanBankMaster INTO @AccountNumber,@Active
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Execute sp_acc_insertaccountsforexistingmasters @AccountNumber,@BANKGROUP,@Active
		update Bank set AccountID=@@Identity where Account_Number=@AccountNumber
		FETCH NEXT FROM ScanBankMaster INTO @AccountNumber,@Active
	END
	CLOSE ScanBankMaster
	DEALLOCATE ScanBankMaster
	

	/*Creating an AccountID in AccountMaster table for each branch and 
	 update the AccountId into the WareHouse table */
	Declare @WareHouseID nvarchar(25)
	Declare @WareHouseName nvarchar(50)
	DECLARE @WAREHOUSEGROUP INT
	SET @WAREHOUSEGROUP=35
	
	DECLARE ScanWareHouseMaster CURSOR KEYSET FOR
	Select WareHouseID,WareHouse_Name,Active from WareHouse where isnull(AccountID,0)=0
	Open ScanWareHouseMaster
	FETCH FROM ScanWareHouseMaster INTO @WareHouseID,@WareHouseName,@Active
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/* Insertion of WareHouse account into the AccountMaster table. */
		Execute sp_acc_insertaccountsforexistingmasters @WareHouseName,@WAREHOUSEGROUP,@Active
		/* Updation of new AccounID into the Customer table. */	
		update WareHouse set AccountID=@@Identity where WareHouseID=@WareHouseID
		FETCH NEXT FROM ScanWareHouseMaster INTO @WareHouseID,@WareHouseName,@Active
	END
	CLOSE ScanWareHouseMaster
	DEALLOCATE ScanWareHouseMaster
	
	/*Update the Miscellaneous AccountID to all adjustment reasons in Adjustment Reason table except default reasons*/
	update AdjustmentReason set AccountID=15 where IsNull(AccountID,0)=0
	
-- 	/* Update the Miscellaneous Account to accountid of DebitNote table except F11 adjustments, bank carges and chq bounce*/
	DECLARE @MISELLANEOUS INT
	DECLARE @BANKCHARGES INT
	SET @MISELLANEOUS=15
	SET @BANKCHARGES=9
-- 	Update DebitNote set AccountID=@MISELLANEOUS where isnull(AccountID,0)=0
-- 	Update CreditNote set AccountID=@MISELLANEOUS where isnull(AccountID,0)=0
	Declare @DebitID Int
	Declare @Flag Int
	Declare @AdjReasonAccountID Int
	Declare @BankID Int,@BankAccountID Int
	DECLARE ScanDebitMaster CURSOR KEYSET FOR
	Select DebitID,Flag from DebitNote where isnull(AccountID,0)=0
	Open ScanDebitMaster
	FETCH FROM ScanDebitMaster INTO @DebitID,@Flag
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @AdjReasonAccountID=AdjustmentReason.AccountID from 
		AdjustmentReference,AdjustmentReason Where AdjustmentReasonID=AdjReasonID  
		and ReferenceID=IsNull(@DebitID,0) and DocumentType=5
		If IsNull(@AdjReasonAccountID,0)<>0
		Begin
			Update DebitNote set AccountID=@AdjReasonAccountID where DebitID = @DebitID and isnull(AccountID,0)=0
		End
		Else
		Begin
			If IsNull(@Flag,0)=1 -- Bank Charges 
			Begin
				Update DebitNote set AccountID=@BANKCHARGES where DebitID = @DebitID and isnull(AccountID,0)=0	
			End
			Else If IsNull(@Flag,0)=2 -- Bounce Cheque
			Begin
				Select @BankID=IsNull(Deposit_To,0) from Collections Where DebitID=@DebitID
				Select @BankAccountID=AccountID from Bank where BankID=@BankID
				If IsNull(@BankAccountID,0) <> 0
				Begin
					Update DebitNote set AccountID=@BankAccountID where DebitID = @DebitID and isnull(AccountID,0)=0	
				End
				Else
				Begin
					Update DebitNote set AccountID=@MISELLANEOUS where DebitID = @DebitID and isnull(AccountID,0)=0	
				End
			End
-- 			Else If IsNull(@Flag,0)=3 -- Claims Settlement (old implementation)
-- 			Begin
-- 				Update DebitNote set AccountID=@MISELLANEOUS where DebitID = @DebitID and isnull(AccountID,0)=0	
-- 			End
			Else 
			Begin
				Update DebitNote set AccountID=@MISELLANEOUS where DebitID = @DebitID and isnull(AccountID,0)=0	
			End

		End
		FETCH NEXT FROM ScanDebitMaster INTO @DebitID,@Flag
	END
	CLOSE ScanDebitMaster
	DEALLOCATE ScanDebitMaster


-- 	/* Update the Miscellaneous Account to accountid of CreditNote table except F11 adjustments */
	Declare @CreditID Int

	DECLARE ScanCreditMaster CURSOR KEYSET FOR
	Select CreditID from CreditNote where isnull(AccountID,0)=0
	Open ScanCreditMaster
	FETCH FROM ScanCreditMaster INTO @CreditID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @AdjReasonAccountID=AdjustmentReason.AccountID from 
		AdjustmentReference,AdjustmentReason Where AdjustmentReasonID=AdjReasonID  
		and ReferenceID=IsNull(@CreditID,0) and DocumentType=2
		If IsNull(@AdjReasonAccountID,0)<>0
		Begin
			Update CreditNote set AccountID=@AdjReasonAccountID where CreditID=@CreditID and isnull(AccountID,0)=0
		End
		Else
		Begin
			Update CreditNote set AccountID=@MISELLANEOUS where CreditID=@CreditID and isnull(AccountID,0)=0	
		End
		FETCH NEXT FROM ScanCreditMaster INTO @CreditID
	END
	CLOSE ScanCreditMaster
	DEALLOCATE ScanCreditMaster
	
	Update FAUpgradeStatus Set Status=1 where ModuleName = @MODULENAME
	Commit Tran
End


