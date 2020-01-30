CREATE Procedure sp_acc_gjexist_Payments
As
DECLARE @DocumentID Int
DECLARE @Status Int
DECLARE @RefDocID Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'Payment'

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

	DECLARE ScanPaymentTransactions CURSOR KEYSET FOR
	Select DocumentID, status,RefDocID from Payments Where DocumentID > @LastUpdatedDocID
	
	Open ScanPaymentTransactions
	FETCH FROM ScanPaymentTransactions INTO @DocumentId, @Status,@RefDocID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran	
		Select @DocDate =DocumentDate,@OpenAccID = dbo.sp_acc_getaccountidfrommaster(VendorID,2), 
		@DocBalance=IsNull(Balance,0) from Payments Where DocumentID=@DocumentId

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
		Begin
			Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where 
			PaymentDetail.DocumentID=@DocumentId and PaymentDetail.PaymentID 
			not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
			and DocumentType=3 -- In PaymentDetail 3-> Advance payment adjustment
			Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
			Set @OpenAccID = IsNull(@OpenAccID,0)
			If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
			Begin
				Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2) 
				Set @OutstandingBalance=0
				Set @OpenAccID=0
			End
			If (IsNull(@status,0) & 64) <> 0 --Previous year pending payments cancelled in current year
			Begin
				Execute sp_acc_gj_existpaymentcancellation @DocumentID
			End
		End
		Else
		Begin
			If (IsNull(@Status,0) & 64) = 0 --not cancelled
			Begin
				If IsNull(@RefDocID,0)=0
				Begin
					--Execute sp_acc_gj_Paymentexist @DocumentID	
					Execute sp_acc_gj_existPayment @DocumentID	
				End
				Else
				Begin
					Execute sp_acc_gj_existPaymentAmendment @DocumentID	
				End
			End
			Else
			Begin
				If IsNull(@RefDocID,0)=0
				Begin
					--Execute sp_acc_gj_Paymentexist @DocumentID	
					Execute sp_acc_gj_existPayment @DocumentID	
				End
				Else
				Begin
					Execute sp_acc_gj_existPaymentAmendment @DocumentID	
				End
			
				Execute sp_acc_gj_existpaymentcancellation @DocumentID
			End
		End
		Update FAUpgradeStatus Set DocumentID=@DocumentID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanPaymentTransactions INTO @DocumentId, @Status,@RefDocID
	END
	CLOSE ScanPaymentTransactions
	DEALLOCATE ScanPaymentTransactions
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End


