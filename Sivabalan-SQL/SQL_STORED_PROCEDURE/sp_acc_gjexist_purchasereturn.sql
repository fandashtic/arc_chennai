CREATE procedure sp_acc_gjexist_purchasereturn
As
DECLARE @AdjustmentID INT
Declare @Status Int
Declare @AdjustmentIDRef Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'PurchaseReturn'

Declare @FiscalYearStart DateTime
Set @FiscalYearStart=dbo.sp_acc_getfiscalyearstart()
Declare @OpenAccID Int
Declare @DocDate DateTime
Declare @DocBalance Decimal(18,6)
Declare @OutstandingBalance Decimal(18,6)

Declare @UpgradeStatus Int,@LastUpdatedDocID Int
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin
	
	DECLARE ScanAdjustmentReturnTransactions CURSOR KEYSET FOR
	Select AdjustmentID,Status from AdjustmentReturnAbstract Where AdjustmentID > @LastUpdatedDocID
	
	OPEN ScanAdjustmentReturnTransactions
	FETCH FROM ScanAdjustmentReturnTransactions into @AdjustmentID,@Status
	WHILE @@FETCH_STATUS=0
	BEGIN
		Begin Tran
		Select @DocDate =AdjustmentDate,@OpenAccID = dbo.sp_acc_getaccountidfrommaster(VendorID,2), 
		@DocBalance=IsNull(Balance,0) from AdjustmentReturnAbstract Where AdjustmentID=@AdjustmentID

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
		Begin
			Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where 
			PaymentDetail.DocumentID=@AdjustmentID and PaymentDetail.PaymentID 
			not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
			and DocumentType=1 -- In PaymentDetail 1->PurchaseReturn
			Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
			Set @OpenAccID = IsNull(@OpenAccID,0)
			If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
			Begin
				Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2) 
				Set @OutstandingBalance=0
				Set @OpenAccID=0
			End
			If (@Status & 64)<>0 --Previous year pending bill cancelled in current year.
			Begin
				Execute sp_acc_gj_closepurchasereturn @AdjustmentID --Purchase Return Cancellation
			End
		End
		Else
		Begin
			If (@Status & 64) = 0 --not cancelled
			Begin
				If IsNull(@AdjustmentIDRef,0)=0
				Begin
					Execute sp_acc_gj_purchasereturn @AdjustmentID
				End
				Else
				Begin
					Execute sp_acc_gj_purchasereturnamendment @AdjustmentID
				End
			End
			Else
			Begin
				If IsNull(@AdjustmentIDRef,0)=0
				Begin
					Execute sp_acc_gj_purchasereturn @AdjustmentID
				End
				Else
				Begin
					Execute sp_acc_gj_purchasereturnamendment @AdjustmentID
				End	
				Execute sp_acc_gj_closepurchasereturn @AdjustmentID --Purchase Return Cancellation
			End
		End
		Update FAUpgradeStatus Set DocumentID=@AdjustmentID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanAdjustmentReturnTransactions INTO @AdjustmentID,@Status
	END
	CLOSE ScanAdjustmentReturnTransactions
	DEALLOCATE ScanAdjustmentReturnTransactions 
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End

