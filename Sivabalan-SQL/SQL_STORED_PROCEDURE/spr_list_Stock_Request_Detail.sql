
CREATE Procedure spr_list_Stock_Request_Detail (@DocSerial int)
As
Select 	"Item Code" = 	stock_request_detail.Product_Code,
	"Item Code" =  	stock_request_detail.Product_Code,
	"Item Name" = 	Items.ProductName, 
	"Quantity" =  	Sum(stock_request_detail.Quantity), 
	"Pending" = 	Sum(stock_request_detail.Pending),
	"Rate" = 	Sum(stock_request_detail.PurchasePrice)
From 	stock_request_detail, Items
Where 	stock_request_detail.Stock_Req_Number = @DocSerial And
	stock_request_detail.Product_Code = Items.Product_Code
Group By 
	stock_request_detail.Product_Code, Items.ProductName
	
	


