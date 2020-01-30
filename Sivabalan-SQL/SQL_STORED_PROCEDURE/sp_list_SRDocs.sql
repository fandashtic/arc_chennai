CREATE PROCEDURE sp_list_SRDocs(@WAREHOUSEID nvarchar(15), @FROMDATE DATETIME,@TODATE DATETIME, @STATUS INT)
as
Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)

SELECT Stock_Request_Abstract.Stock_Req_Number, Stock_Request_Abstract.Stock_Req_Date, 
Status = CASE Stock_Request_Abstract.Status & 32 WHEN 32 THEN @SENT ELSE @NOTSENT END,
Warehouse.WareHouse_Name , Stock_Request_Abstract.warehouseID, 
IsNull(Stock_Request_Abstract.Stk_Req_Prefix, N'') + 
cast(Stock_Request_Abstract.DocumentID as nvarchar)
from  Stock_Request_Abstract, warehouse
WHERE Stock_Request_Abstract.warehouseID LIKE @WAREHOUSEID 
AND (Status & 128 = 0) and (Status & @STATUS) = 0
AND (Stock_Request_Abstract.Stock_Req_Date BETWEEN @FROMDATE AND @TODATE)
AND Stock_Request_Abstract.WarehouseID = warehouse.WarehouseID
ORDER BY warehouse.warehouse_name , Stock_Request_Abstract.Stock_Req_Date


