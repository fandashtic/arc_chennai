CREATE Procedure sp_List_StockTransfer (@WareHouseID nvarchar(50),
					@FromDate datetime,
					@ToDate datetime)
As

Declare @CANCELLED As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)

Select DocSerial, VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),
DocumentDate, StockTransferOutAbstract.WareHouseID, WareHouse.WareHouse_Name,
NetValue, Case 
When (Status & 64) <> 0 then
@CANCELLED
When (Status & 128) <> 0 then
@AMENDED
When (Status & 16) <> 0 then
@AMENDMENT
Else
N''
End, Status From StockTransferOutAbstract, WareHouse, VoucherPrefix
Where StockTransferOutAbstract.WareHouseID like @WareHouseID And
StockTransferOutAbstract.DocumentDate Between @FromDate And @ToDate And
StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID And
VoucherPrefix.TranID = N'STOCK TRANSFER OUT'
Order By StockTransferOutAbstract.WareHouseID, DocSerial, DocumentDate
