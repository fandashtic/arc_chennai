CREATE procedure [dbo].[sp_print_Stock_Request_Items](@Stock_Transer_No INT)  
  
AS  
  
SELECT  "Item Code" = stock_request_detail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Quantity" = Quantity,   
	"UOM" = UOM.Description, 
	"Price" = PurchasePrice, 
	"Pending" = Pending,  
	"Amount" = (Quantity * PurchasePrice)
FROM 	stock_request_detail, Items, UOM  
WHERE stock_request_detail.Stock_Req_Number = @Stock_Transer_No   
AND stock_request_detail.Product_Code = Items.Product_Code  
AND Items.UOM *= UOM.UOM  
order by stock_request_detail.serial
