Create Procedure sp_can_Cancel_STI (@StkTfrID Int)
As
If (Select Count(Batch_Code) From Batch_Products 
Where StockTransferID = @StkTfrID And Quantity <> QuantityReceived) > 0
	Select 0
Else
	Select 1

