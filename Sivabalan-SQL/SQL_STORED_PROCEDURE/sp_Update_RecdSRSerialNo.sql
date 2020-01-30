CREATE Procedure sp_Update_RecdSRSerialNo (@StockRequestNo int, 
					   @StockTransferInNo int)
As
Declare @OriginalSerialNo int

Select @OriginalSerialNo = OriginalSerialNo  From SRAbstractReceived 
Where StockRequestNo = @StockRequestNo
Update StockTransferOutAbstract Set OriginalStockRequest = @OriginalSerialNo,
StockRequestNo = @StockRequestNo
Where DocSerial = @StockTransferInNo
