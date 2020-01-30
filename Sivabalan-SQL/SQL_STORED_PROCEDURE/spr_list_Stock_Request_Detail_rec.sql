
CREATE Procedure spr_list_Stock_Request_Detail_rec (@DocSerial int)  
As  
Select 	"Item Code" =  Stock_Request_Detail_Received.Product_Code,  
	"Item Code" =   Stock_Request_Detail_Received.Product_Code,  
	"Item Name" =  Items.ProductName,   
	"Quantity" =   Sum(Stock_Request_Detail_Received.Quantity),   
	"Pending" =  Sum(Stock_Request_Detail_Received.Pending),  
	"Rate" =  Sum(Stock_Request_Detail_Received.PurchasePrice)  
from 	Stock_Request_Detail_Received, Items  
Where  	Stock_Request_Detail_Received.STK_REQ_Number = @DocSerial And  
	Stock_Request_Detail_Received.Product_Code = Items.Product_Code  
Group By   
	Stock_Request_Detail_Received.Product_Code, Items.ProductName  
     


