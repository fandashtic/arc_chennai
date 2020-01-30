CREATE Procedure sp_List_StockTransferOutRecdLU(@FromDocNo int,
						@ToDocNo int)
As
Select DocSerial, OriginalID,
DocumentDate, StockTransferOutAbstractReceived.WareHouseID, WareHouse.WareHouse_Name,
NetValue, Status From StockTransferOutAbstractReceived, WareHouse
Where StockTransferOutAbstractReceived.WareHouseID = WareHouse.WareHouseID And
StockTransferOutAbstractReceived.DocumentID Between @FromDocNo And @ToDocNo
Order By StockTransferOutAbstractReceived.WareHouseID, DocumentDate
