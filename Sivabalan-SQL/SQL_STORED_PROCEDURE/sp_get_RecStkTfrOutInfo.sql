CREATE PROCEDURE sp_get_RecStkTfrOutInfo
AS
SELECT stocktransferoutabstractreceived.docserial, stocktransferoutabstractreceived.DocumentDate, 
	originalid, warehouse_name, stocktransferoutabstractreceived.warehouseid  ,NetValue, stocktransferoutabstractreceived.creationdate ,  originalid,	
	stocktransferoutabstractreceived.DocumentID,originalid

FROM stocktransferoutabstractreceived, warehouse
WHERE (Status & 128) = 0 AND stocktransferoutabstractreceived.warehouseid = warehouse.warehouseid
order by warehouse_name
