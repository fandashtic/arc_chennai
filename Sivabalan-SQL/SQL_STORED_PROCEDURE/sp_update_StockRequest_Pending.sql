Create Procedure sp_update_StockRequest_Pending (@StkTfrOutNo int, 
						@ItemCode nvarchar(20),
						@Quantity Decimal(18, 2))
As
Declare @StockRequestNo int

Select @StockRequestNo = OriginalStockRequest 
From StockTransferOutAbstractReceived Where DocSerial = @StkTfrOutNo

Update Stock_Request_Detail Set Pending = Pending - @Quantity
Where Stock_Req_Number = @StockRequestNo And
Product_Code = @ItemCode

Update Stock_Request_Detail Set Pending = 0 
Where Stock_Req_Number = @StockRequestNo And
Product_Code = @ItemCode And Pending < 0
