CREATE procedure sp_acc_gjexist_dispatch
As
DECLARE @DispatchID Int
Declare @Status Int
Declare @InvoiceID Int
Declare @InvoiceStatus Int
Declare @OrgRef Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'Dispatch'


Declare @UpgradeStatus Int,@LastUpdatedDocID Int
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin
	DECLARE ScanDispatchTransaction CURSOR KEYSET FOR
	Select DispatchID, status,Original_Reference,InvoiceID from DispatchAbstract
	Where DispatchID > @LastUpdatedDocID And Status <> 128 And Status <> 192
	Open ScanDispatchTransaction
	FETCH FROM ScanDispatchTransaction INTO @DispatchId, @Status,@OrgRef,@InvoiceID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran
		If (IsNull(@Status,0) & 64)=0  --not cancelled
		Begin
			If IsNull(@OrgRef,0)<>0
			Begin
				Execute sp_acc_gj_dispatchamendment @DispatchID
			End
			Else
			Begin
				Execute sp_acc_gj_dispatch @DispatchID
			End
		End
		Else
		Begin
			If IsNull(@InvoiceID,0)=0
			Begin
				If IsNull(@OrgRef,0)<>0
				Begin
					Execute sp_acc_gj_dispatchamendment @DispatchID --Dispatch amendment entry before cancellation
				End
				Else
				Begin
					Execute sp_acc_gj_Dispatch @DispatchID --Dispatch entry before cancellation
				End
				Execute sp_acc_gj_DispatchCancel @DispatchID --Cancellation entry
			End
			Else
			Begin
				Select @InvoiceStatus =IsNull(Status,0) from InvoiceAbstract Where InvoiceID=@InvoiceID 
				If (@InvoiceStatus & 1) <> 0 --Invoice from Dispatch
				Begin
					Execute sp_acc_gj_Dispatch @DispatchID --Dispatch entry before cancellation
				End
			End
		End
		Update FAUpgradeStatus Set DocumentID=@DispatchID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanDispatchTransaction INTO @DispatchId,@Status,@OrgRef,@InvoiceID
	END
	CLOSE ScanDispatchTransaction
	DEALLOCATE ScanDispatchTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End

