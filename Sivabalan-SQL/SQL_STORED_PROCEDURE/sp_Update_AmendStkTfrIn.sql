Create Procedure sp_Update_AmendStkTfrIn (@StkTfrID Int,
					  @StkTfrIDRef Int,
					  @DocumentIDRef nvarchar(255))
As
Update StockTransferInAbstract Set Status = Status | 16, 
DocReference = @DocumentIDRef, Reference = @StkTfrIDRef 
Where DocSerial = @StkTfrID
