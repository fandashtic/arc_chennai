CREATE PROCEDURE sp_list_STODocs(@WAREHOUSEID nvarchar(15), @FROMDATE DATETIME,@TODATE DATETIME, @STATUS INT)
as

Declare @SENT As NVarchar(50)
Declare @NOTSENT As NVarchar(50)

Set @SENT = dbo.LookupDictionaryItem(N'Sent', Default)
Set @NOTSENT = dbo.LookupDictionaryItem(N'Not Sent', Default)


SELECT  stocktransferoutabstract.DocSerial , stocktransferoutabstract.DocumentDate, 
Status = CASE stocktransferoutabstract.Status & 32 WHEN 32 THEN @SENT ELSE @NOTSENT END,
Warehouse.WareHouse_Name , stocktransferoutabstract.warehouseID, 
cast(stocktransferoutabstract.DocPrefix as nvarchar) + 
cast(stocktransferoutabstract.DocumentID as nvarchar)
from  stocktransferoutabstract, warehouse
WHERE stocktransferoutabstract.warehouseID LIKE @WAREHOUSEID 
AND (Status & 128 = 0) and (Status & @STATUS) = 0
AND (DocumentDate BETWEEN @FROMDATE AND @TODATE)
AND stocktransferoutabstract.WarehouseID = warehouse.WarehouseID
ORDER BY warehouse.warehouse_name , documentdate
