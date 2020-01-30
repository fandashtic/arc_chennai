CREATE procedure sp_acc_gjexist_StockTransferIn
As
DECLARE @DocSerial Int
Declare @Status Int
Declare @Reference Int

Declare @MODULENAME as nVarchar(100)
SET @MODULENAME = N'StockTransferIn'

Declare @UpgradeStatus Int,@LastUpdatedDocID Int
--Get upgrade status and last updated document id from FAUpgradeStatus table
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0) 
from FAUpgradeStatus Where ModuleName=@MODULENAME

If @UpgradeStatus=0
Begin

	DECLARE ScanStockTransferInTransaction CURSOR KEYSET FOR
	Select DocSerial, Status,Reference from StockTransferInAbstract Where DocSerial > @LastUpdatedDocID
	
	Open ScanStockTransferInTransaction
	FETCH FROM ScanStockTransferInTransaction INTO @DocSerial, @Status,@Reference
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Begin Tran	
		If (@Status & 64)=0  --not cancelled
		Begin
			If IsNull(@Reference,0) <> 0
			Begin
				Execute sp_acc_gj_StockTransferInamendment @DocSerial
			End
			Else
			Begin
				Execute sp_acc_gj_StockTransferIn @DocSerial
			End
			
		End
	 	Else
	 	Begin
			If IsNull(@Reference,0) <> 0
			Begin
				Execute sp_acc_gj_StockTransferInamendment @DocSerial
			End
			Else
			Begin
				Execute sp_acc_gj_StockTransferIn @DocSerial
			End
			Execute sp_acc_gj_stocktransferinCancel @DocSerial
	 	End
		Update FAUpgradeStatus Set DocumentID=@DocSerial Where ModuleName = @MODULENAME
		Commit Tran
		FETCH NEXT FROM ScanStockTransferInTransaction INTO @DocSerial,@Status,@Reference
	END
	CLOSE ScanStockTransferInTransaction
	DEALLOCATE ScanStockTransferInTransaction
	Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME
End	


