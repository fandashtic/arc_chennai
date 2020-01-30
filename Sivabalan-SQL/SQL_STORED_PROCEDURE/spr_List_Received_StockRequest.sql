Create Procedure [dbo].[spr_List_Received_StockRequest] (@FromDate datetime,
						 @ToDate datetime)
As

Declare @PROCESSED As NVarchar(50)
Declare @NOTPROCESSED As NVarchar(50)

Set @PROCESSED = dbo.LookupDictionaryItem(N'Processed', Default)
Set @NOTPROCESSED = dbo.LookupDictionaryItem(N'Not Processed', Default)

Select SRAbstractReceived.StockRequestNo, 
"Stock Request No" = SRAbstractReceived.OriginalStockRequest,
"Date" = SRAbstractReceived.DocumentDate,
"WareHouse ID" = Case IsNull(SRAbstractReceived.WareHouseID, N'')
When N'' then
SRAbstractReceived.ForumID
Else
SRAbstractReceived.WareHouseID
End,
"WareHouse" = Case IsNull(SRAbstractReceived.WareHouseID, N'')
When N'' then
N''
Else
WareHouse.WareHouse_Name
End,
"Net Value" = SRAbstractReceived.NetValue,
"Status" = Case Status
When 1 then
@NOTPROCESSED
When 33 then
@NOTPROCESSED
Else
@PROCESSED
End
From SRAbstractReceived
Left Outer Join WareHouse on SRAbstractReceived.WareHouseID = WareHouse.WareHouseID
Where 
--SRAbstractReceived.WareHouseID *= WareHouse.WareHouseID And
SRAbstractReceived.DocumentDate Between @FromDate And @ToDate
