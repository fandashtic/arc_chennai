CREATE procedure sp_acc_gjexist_StockTransferOut
As
DECLARE @DocSerial Int
Declare @Status Int
Declare @STOIDRef Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'StockTransferOut'

Declare @UpgradeStatus Int,@LastUpdatedDocID Int
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	DECLARE ScanStockTransferOutTransaction CURSOR KEYSET FOR
	Select DocSerial, Status,STOIDRef from StockTransferOutAbstract Where DocSerial > @LastUpdatedDocID
	
	Open ScanStockTransferOutTransaction
	FETCH FROM ScanStockTransferOutTransaction INTO @DocSerial, @Status,@STOIDRef
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran	
		If (@Status & 64)=0  --not cancelled
		Begin
			If IsNull(@STOIDRef,0)<>0
			Begin
				Execute sp_acc_gj_StockTransferOutamendment @DocSerial
			End
			Else
			Begin
				Execute sp_acc_gj_StockTransferOut @DocSerial
			End
		End
	 	Else
	 	Begin
			If IsNull(@STOIDRef,0)<>0
			Begin
				Execute sp_acc_gj_StockTransferOutamendment @DocSerial
			End
			Else
			Begin
				Execute sp_acc_gj_StockTransferOut @DocSerial
			End
			Execute sp_acc_gj_StockTransferOutCancel @DocSerial
	 	End
		Update FAUpgradeStatus Set DocumentID=@DocSerial Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanStockTransferOutTransaction INTO @DocSerial,@Status,@STOIDRef
	END
	CLOSE ScanStockTransferOutTransaction
	DEALLOCATE ScanStockTransferOutTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End	


