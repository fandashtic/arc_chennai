CREATE PROCEDURE  spr_list_Item_RecStocReq   
(@FROMDATE DATETIME,@TODATE DATETIME)
AS      
SELECT "ITEMCODE"=STOCK_REQUEST_DETAIL_RECEIVED.PRODUCT_CODE,
"Item Code"=STOCK_REQUEST_DETAIL_RECEIVED.PRODUCT_CODE,
"Item Name"=ITEMS.PRODUCTNAME,
"Requested Quantity"=SUM(STOCK_REQUEST_DETAIL_RECEIVED.QUANTITY),
"Pending Quantity"=SUM(STOCK_REQUEST_DETAIL_RECEIVED.PENDING)
FROM 	STOCK_REQUEST_DETAIL_RECEIVED, ITEMS,SRABSTRACTRECEIVED
WHERE STOCK_REQUEST_DETAIL_RECEIVED.PRODUCT_CODE = ITEMS.PRODUCT_CODE
AND STOCK_REQUEST_DETAIL_RECEIVED.STK_REQ_NUMBER=SRABSTRACTRECEIVED.STOCKREQUESTNO
AND SRABSTRACTRECEIVED.DOCUMENTDATE BETWEEN  @FROMDATE  AND  @TODATE
GROUP BY STOCK_REQUEST_DETAIL_RECEIVED.PRODUCT_CODE,ITEMS.PRODUCTNAME
