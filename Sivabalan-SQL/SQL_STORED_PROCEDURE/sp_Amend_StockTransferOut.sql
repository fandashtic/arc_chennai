CREATE Procedure sp_Amend_StockTransferOut (@StockTfrID Int)
As
Declare @BatchCode Int
Declare @Quantity Decimal(18,6)
Declare @bStockRequest Int
Declare @StockRequestNo Int
Declare @Product_Code NVarchar(25)

Select @bStockRequest = Status & 1, @StockRequestNo = StockRequestNo 
From StockTransferOutAbstract 
Where DocSerial = @StockTfrID

Declare RevertStocks Cursor Static For
Select Batch_Code, Quantity, Product_Code From StockTransferOutDetail Where DocSerial = @StockTfrID

Open RevertStocks

Fetch From RevertStocks Into @BatchCode, @Quantity, @Product_Code
While @@Fetch_Status = 0
Begin
	Update Batch_Products Set Quantity = Quantity + @Quantity 
	Where Batch_Code = @BatchCode
	If @bStockRequest = 1
	Begin
		Update Stock_Request_Detail_Received 
		Set Pending = Pending + (@Quantity - IsNull(ExcessQuantity, 0) )
		Where Stk_Req_Number = @StockRequestNo 
		And Product_Code = @Product_Code 
		And Quantity >= Pending + (@Quantity - IsNull(ExcessQuantity, 0) )		
	End
	Fetch Next From RevertStocks Into @BatchCode, @Quantity, @Product_Code
End
Update Stock_Request_Detail_Received 
Set ExcessQuantity = 0
Where Stk_Req_Number = @StockRequestNo		
If @bStockRequest = 1
Begin
	Update SRAbstractReceived Set Status = Status & (~128) Where
	StockRequestNo = @StockRequestNo
End
Update StockTransferOutAbstract Set Status = IsNull(Status, 0) | 128
Where DocSerial = @StockTfrID
Close RevertStocks
DeAllocate RevertStocks

