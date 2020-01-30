
CREATE Procedure sp_list_Pending_StockRequest (@StockRequestNo int)
As
Select Sum(Pending) From Stock_Request_Detail_Received 
Where Stk_Req_Number = @StockRequestNo

