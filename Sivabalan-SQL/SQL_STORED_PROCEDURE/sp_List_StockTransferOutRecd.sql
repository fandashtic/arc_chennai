CREATE Procedure sp_List_StockTransferOutRecd (	@WareHouse nvarchar(20),
						@FromDate datetime,
						@ToDate datetime)
As
Select DocSerial, OriginalID,
DocumentDate, StockTransferOutAbstractReceived.WareHouseID, WareHouse.WareHouse_Name,
NetValue, Status From StockTransferOutAbstractReceived, WareHouse
Where StockTransferOutAbstractReceived.WareHouseID like @WareHouse And
StockTransferOutAbstractReceived.WareHouseID = WareHouse.WareHouseID And
StockTransferOutAbstractReceived.DocumentDate Between @FromDate And @ToDate
Order By StockTransferOutAbstractReceived.WareHouseID, DocumentDate
