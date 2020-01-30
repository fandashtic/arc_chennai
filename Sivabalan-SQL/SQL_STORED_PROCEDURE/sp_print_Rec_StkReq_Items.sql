CREATE procedure [dbo].[sp_print_Rec_StkReq_Items](@Stock_Transer_No INT)  
AS  
SELECT  "Item Code" = Stock_request_detail_received.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Quantity" = Quantity,   
	"UOM" = UOM.Description, 
	"Price" = PurchasePrice, 
	"Pending" = Pending,  
	"Amount" = (Quantity * PurchasePrice)
FROM 	Stock_request_detail_received, Items, UOM  
WHERE Stock_request_detail_received.STK_REQ_Number = @Stock_Transer_No   
AND Stock_request_detail_received.Product_Code = Items.Product_Code  
AND Items.UOM *= UOM.UOM
