CREATE Procedure sp_list_PendingTransfer(@WareHouseID  nvarchar(50),
					 @FromDate datetime,
					 @ToDate datetime)
As
Select DocSerial, DocumentID,
DocumentDate, StockTransferOutAbstractReceived.WareHouseID, WareHouse.WareHouse_Name,
NetValue, OriginalID From StockTransferOutAbstractReceived, WareHouse
Where StockTransferOutAbstractReceived.WareHouseID like @WareHouseID And
StockTransferOutAbstractReceived.WareHouseID = WareHouse.WareHouseID And
StockTransferOutAbstractReceived.DocumentDate Between @FromDate And @ToDate And
(StockTransferOutAbstractReceived.Status & 128) = 0
Order By StockTransferOutAbstractReceived.WareHouseID, DocumentID
