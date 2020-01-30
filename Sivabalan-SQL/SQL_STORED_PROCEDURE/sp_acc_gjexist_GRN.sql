CREATE procedure sp_acc_gjexist_GRN
As
DECLARE @GRNID Int
Declare @Status Int
Declare @GRNIDRef Int
Declare @BillID Int
Declare @BillStatus Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'GRN'

Declare @UpgradeStatus Int,@LastUpdatedDocID Int
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	DECLARE ScanGRNTransaction CURSOR KEYSET FOR
	Select GRNID, GRNStatus,GRNIDRef,BillID From GRNAbstract Where GRNID > @LastUpdatedDocID 
	
	Open ScanGRNTransaction
	FETCH FROM ScanGRNTransaction INTO @GRNId, @Status,@GRNIDRef,@BillID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran	
		If (@Status & 64)=0  --not cancelled
		Begin
			If IsNull(@GRNIDRef,0)=0
			Begin
				Execute sp_acc_gj_GRN @GRNID
			End
			Else If IsNull(@GRNIDRef,0)<>0 --and IsNull(@BillID,0) =0 
			Begin
				Execute sp_acc_gj_GRNAmendment @GRNID
			End
		End
		Else
		Begin
			If IsNull(@BillID,0)=0
			Begin
				If IsNull(@GRNIDRef,0)=0
				Begin
					Execute sp_acc_gj_GRN @GRNID --GRN entry before cancellation
				End
				Else If IsNull(@GRNIDRef,0)<>0 --and IsNull(@BillID,0) =0 
				Begin
					Execute sp_acc_gj_GRNAmendment @GRNID
				End
				Execute sp_acc_gj_GRNCancellation @GRNID --Cancellation entry
			End
			Else
			Begin
				Select @BillStatus =IsNull(Status,0) from BillAbstract Where BillID=@BillID 
				If (@BillStatus & 1) <> 0 --Bill from GRN
				Begin
					Execute sp_acc_gj_GRN @GRNID --GRN entry
				End
			End
		End
		Update FAUpgradeStatus Set DocumentID=@GRNID Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanGRNTransaction INTO @GRNId,@Status,@GRNIDRef,@BillID
	END
	CLOSE ScanGRNTransaction
	DEALLOCATE ScanGRNTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End

