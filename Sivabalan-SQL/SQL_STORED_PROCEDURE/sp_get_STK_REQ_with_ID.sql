CREATE procedure [dbo].[sp_get_STK_REQ_with_ID] (@STK_DOC_ID int)    
as     
declare @STK_REQ_NO int
select @STK_REQ_NO = Stock_Req_Number from stock_request_abstract where documentid = @STK_DOC_ID
SELECT  "Item Code" = stock_request_detail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Quantity" = Quantity,   
	"UOM" = UOM.Description, 
	"Price" = PurchasePrice, 
	"Pending" = Pending,  
	"Amount" = (Quantity * PurchasePrice),
	"WarehouseID" = stock_request_abstract.warehouseid,
	"WarehouseName" = warehouse.warehouse_name,
	"requireddate" = stock_request_abstract.requireddate,
	"StockReqDate" = stock_request_abstract.Stock_Req_Date,
	"ShippingAdd" = stock_request_abstract.shippingaddress

FROM 	stock_request_detail, Items, UOM  , stock_request_abstract, Warehouse
WHERE 	stock_request_detail.Stock_Req_Number = @STK_REQ_NO    and
	stock_request_abstract.Stock_Req_Number = stock_request_detail.Stock_Req_Number and
	Warehouse.warehouseid = stock_request_abstract.warehouseid
	AND stock_request_detail.Product_Code = Items.Product_Code  
	AND Items.UOM *= UOM.UOM
