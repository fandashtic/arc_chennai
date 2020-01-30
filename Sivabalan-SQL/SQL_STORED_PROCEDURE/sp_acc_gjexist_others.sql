CREATE Procedure sp_acc_gjexist_others
As
Declare @DebitID Int 
Declare @CreditID Int
Declare @ClaimID Int
Declare @status Int --status of claims note
Declare @SettlementType Int
Declare @Balance Decimal(18,6)

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'DebitNote'

Declare @FiscalYearStart DateTime
Set @FiscalYearStart=dbo.sp_acc_getfiscalyearstart()
Declare @OpenAccID Int
Declare @DocDate DateTime
Declare @DocBalance Decimal(18,6)
Declare @OutstandingBalance Decimal(18,6)
Declare @CustomerID nvarchar(255)
Declare @VendorID nvarchar(255)

Declare @UpgradeStatus Int,@LastUpdatedDocID Int
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	/* DebitNote for customer/vendor transactions */ 
	DECLARE ScanDebitNoteTransaction CURSOR KEYSET FOR
	Select DebitID,Status from DebitNote Where DebitID > @LastUpdatedDocID and 
	DebitID  not in (Select IsNull(ReferenceID,0) from AdjustmentReference where DocumentType=5) and --avoid journal for F11 adjustments
	IsNull(Flag,0) = 0  --avoid journal for claims settlement,bank charges, bounced chqs.

	Open ScanDebitNoteTransaction
	FETCH FROM ScanDebitNoteTransaction INTO @DebitId,@Status
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran
-- 		Select @DocDate =DocumentDate,@CustomerID=CustomerID,@VendorID=VendorID,@OpenAccID = Select Case CustomerID is Not Null Then dbo.sp_acc_getaccountid(CustomerID,1) Else dbo.sp_acc_getaccountid(VendorID,2) End, 
-- 		@DocBalance=IsNull(Balance,0) from DebitNote Where DebitID=@DebitId
		Select @DocDate =DocumentDate,@CustomerID=CustomerID,@VendorID=VendorID,
		@DocBalance=IsNull(Balance,0) from DebitNote Where DebitID=@DebitId

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
		Begin
			If @CustomerID Is Not Null
			Begin
				Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from CollectionDetail Where 
				CollectionDetail.DocumentID=@DebitId and CollectionDetail.CollectionID 
				not in (Select Collections.DocumentID from Collections Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
				and DocumentType=5 -- In CollectionsDetail 5->DebitNote
				Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
				Set @OpenAccID = IsNull(dbo.sp_acc_getaccountidfrommaster(@CustomerID,1),0)
				If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
				Begin
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
					Set @OutstandingBalance=0
					Set @OpenAccID=0
					Set @CustomerID=N''
				End
			End
			Else
			Begin
				Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where 
				PaymentDetail.DocumentID=@DebitId and PaymentDetail.PaymentID 
				not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
				and DocumentType=2 -- In PaymentsDetail 2->DebitNote
				Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
				Set @OpenAccID = IsNull(dbo.sp_acc_getaccountidfrommaster(@VendorID,2),0)
				If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
				Begin
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2) 
					Set @OutstandingBalance=0
					Set @OpenAccID=0
					Set @VendorID=N''
				End
			End
		End
		Else
		Begin		
			If (IsNull(@Status,0) & 64) = 0 --Not Cancelled
			Begin
				Execute sp_acc_gj_existdebitnote @DebitID
			End
			Else
			Begin
				Execute sp_acc_gj_existdebitnote @DebitID -- before cancellation
				Execute sp_acc_gj_existdebitnotecancel @DebitID --Cancellation
			End
		End
		Update FAUpgradeStatus Set DocumentID=@DebitID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanDebitNoteTransaction INTO @DebitId,@status
	END
	CLOSE ScanDebitNoteTransaction
	DEALLOCATE ScanDebitNoteTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End

SET @MODULENAME = N'CreditNote'
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	/* CreditNote for customer/vendor transactions*/
	DECLARE ScanCreditNoteTransaction CURSOR KEYSET FOR
	Select CreditID,Status from CreditNote Where CreditID > @LastUpdatedDocID and
	CreditID not in (Select IsNull(ReferenceID,0) from AdjustmentReference where DocumentType=2) --avoid journal for F11 adjustments
	
	Open ScanCreditNoteTransaction
	FETCH FROM ScanCreditNoteTransaction INTO @CreditId,@Status
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran
-- 		Select @DocDate =DocumentDate,@CustomerID=CustomerID,@VendorID=VendorID,@OpenAccID = Select Case CustomerID is Not Null Then dbo.sp_acc_getaccountid(CustomerID,1) Else dbo.sp_acc_getaccountid(VendorID,2) End, 
-- 		@DocBalance=IsNull(Balance,0) from DebitNote Where DebitID=@DebitId
		Select @DocDate =DocumentDate,@CustomerID=CustomerID,@VendorID=VendorID,
		@DocBalance=IsNull(Balance,0) from CreditNote Where CreditID=@CreditId

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
		Begin
			If @CustomerID Is Not Null
			Begin
				Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from CollectionDetail Where 
				CollectionDetail.DocumentID=@CreditId and CollectionDetail.CollectionID 
				not in (Select Collections.DocumentID from Collections Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
				and DocumentType=2 -- In CollectionsDetail 5->CreditNote
				Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
				Set @OpenAccID = IsNull(dbo.sp_acc_getaccountidfrommaster(@CustomerID,1),0)
				If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
				Begin
					Set @OutstandingBalance=0-IsNull(@OutstandingBalance,0)
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
					Set @OutstandingBalance=0
					Set @OpenAccID=0
					Set @CustomerID=N''
				End
			End
			Else
			Begin
				Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where 
				PaymentDetail.DocumentID=@CreditId and PaymentDetail.PaymentID 
				not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
				and DocumentType=5 -- In PaymentsDetail 5->CreditNote
				Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
				Set @OpenAccID = IsNull(dbo.sp_acc_getaccountidfrommaster(@VendorID,2),0)
				If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
				Begin
					Set @OutstandingBalance=0-IsNull(@OutstandingBalance,0)
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2) 
					Set @OutstandingBalance=0
					Set @OpenAccID=0
					Set @VendorID=N''
				End
			End
		End
		Else
		Begin
			If (IsNull(@Status,0) & 64 ) = 0 -- not cancelled
			Begin
				Execute sp_acc_gj_creditnote @creditID
			End
			Else
			Begin
				Execute sp_acc_gj_creditnote @creditID -- Before Cancellation
				Execute sp_acc_gj_creditnoteCancel @creditID -- Cancellation
			End
		End
		Update FAUpgradeStatus Set DocumentID=@creditID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanCreditNoteTransaction INTO @CreditId,@status
	END
	CLOSE ScanCreditNoteTransaction
	DEALLOCATE ScanCreditNoteTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End

-- /* ClaimsNote transactions */
SET @MODULENAME = N'ClaimsNote'
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	 DECLARE ScanClaimsTransaction CURSOR KEYSET FOR
	 Select ClaimID, Status,SettlementType,Balance from ClaimsNote Where ClaimID > @LastUpdatedDocID and IsNull(SettlementType,0) <> 1 --No Debit note will be raised for Free Replacement settlement type.
	 OPEN ScanClaimsTransaction
	 FETCH FROM ScanClaimsTransaction INTO @ClaimID, @Status,@SettlementType,@Balance
	 While @@FETCH_STATUS=0
	 Begin
		Begin Tran -- Journal for claim settlement  (Previous implementation) 
		Select @DocDate = ClaimDate,@VendorID = VendorID,
		@DocBalance = IsNull(Balance,0) from ClaimsNote Where ClaimID = @ClaimID
		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
			Begin
				If @VendorID Is Not NULL
					Begin
						Select @OutstandingBalance = Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where 
						PaymentDetail.DocumentID = @ClaimID and PaymentDetail.PaymentID 
						not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
						and DocumentType = 6 -- In PaymentsDetail 6-> ClaimsNote
						Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
						Set @OpenAccID = IsNull(dbo.sp_acc_getaccountidfrommaster(@VendorID,2),0)
						If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
							Begin
								Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2) 
								Set @OutstandingBalance=0
								Set @OpenAccID=0
								Set @VendorID=N''
							End
					End
			End
		Else
			Begin
				If IsNull(@SettlementType,0) =2 and (IsNull(@Status,0) & 128) <> 0 and IsNull(@Balance,0) = 0
					Begin
						Execute sp_acc_gj_Claimssettlement @ClaimID 
						Update FAUpgradeStatus Set DocumentID=@ClaimID Where ModuleName = @MODULENAME
					End
				Else  -- Journal for claim raise (Current implementation)
					Begin
					 	If (@Status & 64) <> 0 --Claims Cancellation
						 	Begin
						 		Execute sp_acc_gj_claims @ClaimID --Claims entry before cancellation
						 		Execute sp_acc_gj_closeclaims @ClaimID --Claims cancellation entry
						 	End
					 	Else
						 	Begin
						 		Execute sp_acc_gj_claims @ClaimID --Claims entry
						 	End
						Update FAUpgradeStatus Set DocumentID=@ClaimID Where ModuleName = @MODULENAME
					End 
			End
		Commit Tran
	 	FETCH NEXT FROM ScanClaimsTransaction INTO @ClaimID, @Status,@SettlementType,@Balance
	 End
	 CLOSE ScanClaimsTransaction
	 DEALLOCATE ScanClaimsTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End
