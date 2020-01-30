CREATE Procedure sp_update_Items_ItemCode (@Product_Code nvarchar(20),
					   @ForumCode nvarchar(20))
As
Update StockTransferOutDetailReceived Set Product_Code = @Product_Code
Where ForumCode = @ForumCode
Update ItemsReceivedDetail Set Product_Code = @Product_Code 
Where ForumCode = @ForumCode
Update stock_request_detail_received Set Product_Code = @Product_Code 
Where ForumCode = @ForumCode
Update InvoiceDetailReceived Set Product_Code = @Product_Code 
Where ForumCode = @ForumCode
Update ClaimsDetailReceived Set Product_Code = @Product_Code
Where ForumCode = @ForumCode
