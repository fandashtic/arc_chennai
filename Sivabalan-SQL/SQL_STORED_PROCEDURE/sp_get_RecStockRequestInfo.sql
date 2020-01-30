CREATE Procedure sp_get_RecStockRequestInfo
As
Select SRAbstractReceived.StockRequestNo, SRAbstractReceived.DocumentDate, Null, 
WareHouse.WareHouse_Name, SRAbstractReceived.WareHouseID, SRAbstractReceived.NetValue,
Isnull(SRAbstractReceived.CreationDate,getdate()), SRAbstractReceived.OriginalStockRequest
From SRAbstractReceived, WareHouse
Where IsNull(SRAbstractReceived.Status, 0) in (0, 32, 1, 33) And
SRAbstractReceived.WareHouseID = WareHouse.WareHouseID
Order By WareHouse.WareHouse_Name, SRAbstractReceived.DocumentDate

