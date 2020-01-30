CREATE procedure [dbo].[spr_List_Received_StockRequest_Detail] (@StockRequestNo int)
As
Select Stock_Request_Detail_Received.Stk_Req_Number,
"Item Code" = Case IsNull(Stock_Request_Detail_Received.Product_Code, N'')
When N'' then
Stock_Request_Detail_Received.ForumCode
Else
Stock_Request_Detail_Received.Product_Code
End,
"Item Name" = Case IsNull(Stock_Request_Detail_Received.Product_Code, N'')
When N'' then
N''
Else
Items.ProductName
End,
"Purchase Price" = Max(Stock_Request_Detail_Received.PurchasePrice),
"Req Qty" = Sum(Stock_Request_Detail_Received.Quantity),
"Pending" = Sum(Stock_Request_Detail_Received.Pending)
From Stock_Request_Detail_Received, Items
Where Stock_Request_Detail_Received.Stk_Req_Number = @StockRequestNo And
Stock_Request_Detail_Received.Product_Code *= Items.Product_Code
Group By Stock_Request_Detail_Received.Stk_Req_Number, 
Stock_Request_Detail_Received.ForumCode, 
Stock_Request_Detail_Received.Product_Code,
Items.ProductName
