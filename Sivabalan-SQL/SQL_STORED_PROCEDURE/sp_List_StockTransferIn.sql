CREATE Procedure sp_List_StockTransferIn (@WareHouse nvarchar(20),
					  @FromDate datetime,
					  @ToDate datetime)
As
Select DocSerial, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar),
DocumentDate, StockTransferInAbstract.WareHouseID, WareHouse.WareHouse_Name,
StockTransferInAbstract.NetValue, StockTransferInAbstract.Status, 
StockTransferInAbstract.ReferenceSerial
From StockTransferInAbstract, WareHouse, VoucherPrefix
Where StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID And
StockTransferInAbstract.WareHouseID like @WareHouse And
StockTransferInAbstract.DocumentDate Between @FromDate And @ToDate And
VoucherPrefix.TranID = 'STOCK TRANSFER IN'
Order By WareHouse.WareHouse_Name, DocSerial, DocumentDate
