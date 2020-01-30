
CREATE Procedure sp_List_StockRequestRecd (@WareHouseID nvarchar(50),
					@FromDate datetime,
					@ToDate datetime)
As
Select StockRequestNo, OriginalStockRequest,
DocumentDate, SRAbstractReceived.WareHouseID, WareHouse.WareHouse_Name,
NetValue, Status From SRAbstractReceived, WareHouse
Where SRAbstractReceived.WareHouseID like @WareHouseID And
SRAbstractReceived.DocumentDate Between @FromDate And @ToDate And
SRAbstractReceived.WareHouseID = WareHouse.WareHouseID And
IsNull(SRAbstractReceived.WareHouseID, N'') <> N'' And
IsNull(SRAbstractReceived.Status, 1) & 128 = 0
Order By SRAbstractReceived.WareHouseID, StockRequestNo, DocumentDate


