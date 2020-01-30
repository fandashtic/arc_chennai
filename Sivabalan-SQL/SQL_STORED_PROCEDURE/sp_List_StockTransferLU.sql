CREATE Procedure sp_List_StockTransferLU (@FromDocID int, @ToDocID int)
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
When (Status & 64) <> 0 Then
@CANCELLED
When (Status & 128) <> 0 then
@AMENDED
When (Status & 16) <> 0 then
@AMENDMENT
Else
N''
End,
Status From StockTransferOutAbstract, WareHouse, VoucherPrefix
Where StockTransferOutAbstract.DocumentID Between @FromDocID And @ToDocID And
StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID And
VoucherPrefix.TranID = N'STOCK TRANSFER OUT'
Order By StockTransferOutAbstract.WareHouseID, DocSerial, DocumentDate


