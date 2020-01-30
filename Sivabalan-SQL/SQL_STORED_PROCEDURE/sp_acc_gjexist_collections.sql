CREATE Procedure sp_acc_gjexist_collections
As
DECLARE @DocumentID Int
DECLARE @Status Int
Declare @Realised Int
Declare @RefDocID Int
Declare @DepositDate DateTime
Declare @DepositTo Int
Declare @Value  Decimal(18,6)
Declare @DepositID Int
Declare @InvStatus Int

DECLARE @COLLECTION INT --status
DECLARE @DEPOSIT INT --status
DECLARE @CANCEL INT --status
SET @COLLECTION=0
SET @DEPOSIT=1
SET @CANCEL=192

DECLARE @BOUNCED INT --Realised
DECLARE @REPRESENT INT --Realised
SET @BOUNCED=2
SET @REPRESENT=3

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'Collection'

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

	DECLARE ScanCollectionTransactions CURSOR KEYSET FOR
	Select DocumentID, Value,status,DepositDate,Deposit_To, Realised,RefDocID from 
	Collections Where DocumentID > @LastUpdatedDocID --and DocumentID not in (Select ColDocumentID from TempImplicitCollection)
	
	Open ScanCollectionTransactions
	FETCH FROM ScanCollectionTransactions INTO @DocumentId,@Value, @Status,@DepositDate,@DepositTo, @Realised,@RefDocID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran	
		Select @DocDate =DocumentDate,@OpenAccID = dbo.sp_acc_getaccountidfrommaster(CustomerID,1), 
		@DocBalance=IsNull(Balance,0) from Collections Where DocumentID=@DocumentId

		If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart
		Begin
			Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from CollectionDetail Where 
			CollectionDetail.DocumentID=@DocumentId and CollectionDetail.CollectionID 
			not in (Select Collections.DocumentID from Collections Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart) 
			and DocumentType=3 -- In CollectionsDetail 3-> Advance collection adjustment
			Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)
			Set @OpenAccID = IsNull(@OpenAccID,0)
			If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0
			Begin
				Set @OutstandingBalance=0-IsNull(@OutstandingBalance,0)
				Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
				Set @OutstandingBalance=0
				Set @OpenAccID=0
			End
			If (IsNull(@status,0) & 64) <> 0 --Previous year pending collection cancelled in current year
			Begin
				Execute sp_acc_gj_CollectionCancel @DocumentID
			End
		End
		Else
		Begin
			--Customer outstanding has to be considered previous year documents adjusted in current year before close period.
			Set @OutstandingBalance=IsNull(dbo.sp_acc_gjexist_Collections_AddOpening(@DocumentId,@FiscalYearStart),0)
			If IsNull(@OutstandingBalance,0)<>0
			Begin
				Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,1) 
				Set @OutstandingBalance=0
				Set @OpenAccID=0
			End

			If (IsNull(@status,0) & 64) = 0 --not cancelled
			Begin
				If (isnull(@Status,0) = @DEPOSIT) and (isnull(@Realised,0) = 0 or isnull(@Realised,0) = 1)
				Begin
					If Not Exists(Select ColDocumentID from TempImplicitCollection Where ColDocumentID=@DocumentId)
					Begin
						If IsNull(@RefDocID ,0) <> 0
						Begin
							Execute sp_acc_gj_collectionAmendment @DocumentID	
						End
						Else
						Begin
							Execute sp_acc_gj_collections @DocumentID	
						End
					End
					--Inserting Deposit record into Deposit table and update the Deposit ID into Collections
					--and journal entry passed for deposits.
					Execute sp_acc_insertdeposits @DepositDate, @DepositTo,@Value,0 --StaffID
					Set @DepositID =@@Identity
					Update Collections Set DepositID=@DepositID Where DocumentID=@DocumentID
					Execute sp_acc_gj_Deposits @DepositID
					Set @DepositID=0
				End
				Else if (isnull(@Status,0) = @DEPOSIT) and (isnull(@Realised,0) = @BOUNCED or isnull(@Realised,0)=@REPRESENT)
				Begin
					If Not Exists(Select ColDocumentID from TempImplicitCollection Where ColDocumentID=@DocumentId)
					Begin
						If IsNull(@RefDocID ,0) <> 0
						Begin
							Execute sp_acc_gj_collectionAmendment @DocumentID	
						End
						Else
						Begin
							Execute sp_acc_gj_collections @DocumentID	
						End
					End
					--Inserting Deposit record into Deposit table and update the Deposit ID into Collections
					--and journal entry passed for deposits.
					Execute sp_acc_insertdeposits @DepositDate, @DepositTo,@Value,0 --StaffID
					Set @DepositID =@@Identity
					Update Collections Set DepositID=@DepositID Where DocumentID=@DocumentID
					Execute sp_acc_gj_Deposits @DepositID
					Set @DepositID=0		
					Execute sp_acc_gj_chequebounce @DocumentID
				End
				Else If  (isnull(@Realised,0) = 0)
				Begin
					If Not Exists(Select ColDocumentID from TempImplicitCollection Where ColDocumentID=@DocumentId)
					Begin
						If IsNull(@RefDocID ,0) <> 0
						Begin
							Execute sp_acc_gj_collectionAmendment @DocumentID	
						End
						Else
						Begin
							Execute sp_acc_gj_collections @DocumentID	
						End
					End
				End
			End
			Else if (@status & 64) <> 0 --Cancel status 
			Begin
				If Not Exists(Select ColDocumentID from TempImplicitCollection Where ColDocumentID=@DocumentId)
				Begin
					 --Collection entry before cancellation
					If IsNull(@RefDocID ,0) <> 0
					Begin
						Execute sp_acc_gj_collectionAmendment @DocumentID	
					End
					Else
					Begin
						Execute sp_acc_gj_collections @DocumentID	
					End
					Execute sp_acc_gj_CollectionCancel @DocumentID --Cancellation entry
				End
				Else
				Begin
					Select @InvStatus=IsNull(Status,0) from InvoiceAbstract Where Cast(PaymentDetails as Int)=@DocumentID And InvoiceType <> 2
					If (IsNull(@InvStatus,0) & 192)=0 --Invoice not cancelled but implicit collection cancelled.
					Begin
						Execute sp_acc_gj_CollectionCancel @DocumentID --Cancellation entry
					End
				End
			End
		End
		Update FAUpgradeStatus Set DocumentID=@DocumentID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanCollectionTransactions INTO @DocumentId,@Value, @Status,@DepositDate,@DepositTo,@Realised,@RefDocID
	END
	CLOSE ScanCollectionTransactions
	DEALLOCATE ScanCollectionTransactions
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End	

