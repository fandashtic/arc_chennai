CREATE Procedure sp_View_StockTransferOutAbstractReceived (@DocSerial int)
As
Select DocSerial, OriginalID,
DocumentDate, StockTransferOutAbstractReceived.WareHouseID, WareHouse.WareHouse_Name,
NetValue, Status, Null, TaxAmount
From StockTransferOutAbstractReceived, WareHouse
Where StockTransferOutAbstractReceived.DocSerial = @DocSerial And
StockTransferOutAbstractReceived.WareHouseID = WareHouse.WareHouseID
