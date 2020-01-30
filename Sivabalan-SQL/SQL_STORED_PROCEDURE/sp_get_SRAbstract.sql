
Create Procedure sp_get_SRAbstract (@StockRequestNo int)
As
Select OriginalStockRequest, DocumentDate, SRAbstractReceived.WareHouseID, 
WareHouse.WareHouse_Name, NetValue, WareHouse.Address 
From SRAbstractReceived, WareHouse
Where SRAbstractReceived.StockRequestNo = @StockRequestNo And
SRAbstractReceived.WareHouseID = WareHouse.WareHouseID


