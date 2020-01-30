Create Procedure sp_Update_AmendStkTfrOut (@StkTfrID Int,
					   @StkTfrIDRef Int,
					   @DocumentIDRef nvarchar(255))
As
Update StockTransferOutAbstract Set STOIDRef = @StkTfrIDRef,
STODOCIDRef = @DocumentIDRef Where DocSerial = @StkTfrID
