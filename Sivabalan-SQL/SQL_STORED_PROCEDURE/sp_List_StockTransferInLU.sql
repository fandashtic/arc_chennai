CREATE Procedure sp_List_StockTransferInLU (@FromDocNo int,
					    @ToDocNo int)
As
Select DocSerial, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar),
DocumentDate, StockTransferInAbstract.WareHouseID, WareHouse.WareHouse_Name,
StockTransferInAbstract.NetValue, StockTransferInAbstract.Status, 
StockTransferInAbstract.ReferenceSerial
From StockTransferInAbstract, WareHouse, VoucherPrefix
Where StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID And
VoucherPrefix.TranID = 'STOCK TRANSFER IN' And
StockTransferInAbstract.DocumentID Between @FromDocNo And @ToDocNo
Order By WareHouse.WareHouse_Name, DocSerial, DocumentDate
