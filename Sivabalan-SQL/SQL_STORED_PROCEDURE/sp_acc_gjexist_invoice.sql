CREATE procedure sp_acc_gjexist_invoice
As
DECLARE @InvoiceID Int
DECLARE @InvoiceType Int
Declare @Status Int
Declare @InvoiceReference nVarchar(255)

DECLARE @INVOICE INT
DECLARE @RETAILINVOICE INT
DECLARE @AMENDMENTINVOICE INT
DECLARE @SALESRETURN INT
SET @INVOICE=1
SET @RETAILINVOICE=2
SET @AMENDMENTINVOICE=3
SET @SALESRETURN=4

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'Invoice'

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
	DECLARE ScanInvoiceTransaction CURSOR KEYSET FOR
	Select InvoiceID, InvoiceType, Status, InvoiceReference from InvoiceAbstract
	Where InvoiceID > @LastUpdatedDocID
	
	Open ScanInvoiceTransaction
	FETCH FROM ScanInvoiceTransaction INTO @InvoiceId, @InvoiceType, @Status, @InvoiceReference
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran
		Select @DocDate =InvoiceDate,@OpenAccID = dbo.sp_acc_getaccountidfrommaster(CustomerID,1), 
		@DocBalance=IsNull(Balance,0) from InvoiceAbstract Where InvoiceID=@InvoiceId

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart and @InvoiceType <> @RETAILINVOICE
		Begin
			Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from CollectionDetail Where 
			CollectionDetail.DocumentID=@InvoiceId and CollectionDetail.CollectionID 
			not in (Select Collections.DocumentID from Collections Where (IsNull(Status,0) & 64) <> 0 or DocumentDate < @FiscalYearStart) 
			and (DocumentType=4 or DocumentType=1) -- In CollectionsDetail 4->Invoice and 1-> SalesReturn
			Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
			Set @OpenAccID = IsNull(@OpenAccID,0)
			If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
			Begin
				If @InvoiceType = @INVOICE
				Begin
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
				End
				Else If @InvoiceType = @SALESRETURN
				Begin
					Set @OutstandingBalance=0-IsNull(@OutstandingBalance,0)
					Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
				End
				Set @OutstandingBalance=0
				Set @OpenAccID=0
			End
			If (@Status & 64)<>0 --If previous pending invoice cancelled in current year
			Begin
				If @InvoiceType = @INVOICE
				Begin
					Execute sp_acc_gj_InvoiceCancel @InvoiceID
				End
				Else If @InvoiceType = @SALESRETURN
				Begin
					
					Execute sp_acc_gj_salesreturncancellation @InvoiceID
				End
			End 
		End
		Else
		Begin 
			If @InvoiceType = @INVOICE
			Begin
				If (@Status & 64)=0  --not cancelled
				Begin
					Execute sp_acc_gjexistinvoice_adjustments @InvoiceID --Inserting Credit/Debit note for adjustments
					--Execute sp_acc_gj_existInvoice @InvoiceID
					Execute sp_acc_gj_existInvoice @InvoiceID
				End
				Else
				Begin
					Execute sp_acc_gjexistinvoice_adjustments @InvoiceID --Adjustment entries before cancellation
					--Execute sp_acc_gj_existInvoice @InvoiceID --Invoice entry before cancellation
					--Execute sp_acc_gj_existInvoiceCancel @InvoiceID --Cancellation entry
					Execute sp_acc_gj_existInvoice @InvoiceID --Invoice entry before cancellation
					Execute sp_acc_gj_InvoiceCancel @InvoiceID --Cancellation entry
				End
			End
			Else if @InvoiceType = @RETAILINVOICE
			Begin
				--Update Paymentdetails before posting journal entries for retail invoices
				Update InvoiceAbstract 
				Set PaymentDetails = N'Cash:' + CAST((IsNull(NetValue,0) + IsNull(RoundOffAmount,0))As nVarchar) + N'::0', 
				AmountRecd = (IsNull(NetValue,0) + IsNull(RoundOffAmount,0))
				Where InvoiceType = 2 and PaymentDetails is Null
				If (@Status & 64)=0 --not cancelled
				Begin
					If isnull(dbo.gettrueval(@InvoiceReference),N'')=N''
					Begin
						Execute sp_acc_gj_retailInvoice @InvoiceID
					End
					Else
					Begin
						Execute sp_acc_gj_retailinvoiceamendment @InvoiceID
					End		
				End
				Else
				Begin
					--Entries before Cancel retail invoice
					If isnull(dbo.gettrueval(@InvoiceReference),N'')=N''
					Begin
						Execute sp_acc_gj_retailInvoice @InvoiceID
					End
					Else
					Begin
						Execute sp_acc_gj_retailinvoiceamendment @InvoiceID
					End		
					--Cancel Retail Invoice
					Execute sp_acc_gj_retailinvoicecancel @InvoiceID
				End
			End
			Else if @InvoiceType = @AMENDMENTINVOICE
			Begin
				If (@status & 64)=0  --not cancelled
				Begin
					Execute sp_acc_gjexistinvoice_adjustments @InvoiceID --Inserting Credit/Debit note for adjustments
					--Execute sp_acc_gj_existInvoiceAmendment @InvoiceID --I dono y this procedure used previously
					Execute sp_acc_gj_existInvoiceAmendment @InvoiceID
				End
				Else
				Begin
					Execute sp_acc_gjexistinvoice_adjustments @InvoiceID --Inserting Credit/Debit note for adjustments
					--Execute sp_acc_gj_existInvoiceAmendment @InvoiceID --Before cancel entry
					--Execute sp_acc_gj_existInvoiceCancel @InvoiceID --Cancel Entry
					Execute sp_acc_gj_existInvoiceAmendment @InvoiceID --Before cancel entry
					Execute sp_acc_gj_InvoiceCancel @InvoiceID --Cancel Entry
			
				End
			End
			Else if @InvoiceType = @SALESRETURN
			Begin
				If (IsNull(@Status,0) & 64) = 0 -- Not cancelled
				Begin
					Execute sp_acc_gj_SalesReturn @InvoiceID
				End
				Else
				Begin
					Execute sp_acc_gj_SalesReturn @InvoiceID
					Execute sp_acc_gj_salesreturncancellation @InvoiceID
				End
			End
		End
		Update FAUpgradeStatus Set DocumentID=@InvoiceID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanInvoiceTransaction INTO @InvoiceId, @InvoiceType, @Status, @InvoiceReference
	END
	CLOSE ScanInvoiceTransaction
	DEALLOCATE ScanInvoiceTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End
