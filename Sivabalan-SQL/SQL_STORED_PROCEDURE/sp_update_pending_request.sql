CREATE Procedure sp_update_pending_request (@StockRequestNo int,
					    @ProductCode nvarchar(20),
					    @Quantity Decimal(18,6))
As
Update Stock_Request_Detail_Received Set ExcessQuantity = @Quantity - Pending
Where Stk_Req_Number = @StockRequestNo And 
Product_Code = @ProductCode And
@Quantity - Pending > 0

Update Stock_Request_Detail_Received Set Pending = Pending - @Quantity
Where Stk_Req_Number = @StockRequestNo And 
Product_Code = @ProductCode

Update Stock_Request_Detail_Received Set Pending = 0
Where Stk_Req_Number = @StockRequestNo And 
Product_Code = @ProductCode And
Pending < 0
