CREATE Procedure sp_Amend_StkTfrIn (	@StkTfrID Int,
					@OpeningDate Datetime)
As
Declare @ItemCode nvarchar(20)
Declare @Quantity Decimal(18,6)
Declare @Price Decimal(18,6)
Declare @Free Int
Declare @BATCH_CODE Int

If (Select Count(Batch_Code) From Batch_Products Where StockTransferID = @StkTfrID) = 0
Begin
	Select 0
	GoTo Finish
End
Else If (Select Count(Batch_Code) From Batch_Products Where StockTransferID = @StkTfrID And 
Quantity <> QuantityReceived) > 0
Begin
	Select 0
	GoTo Finish
End
Else
Begin
	Update StockTransferInAbstract Set Status = Status | 128 Where DocSerial = @StkTfrID

	Declare UndoOpening Cursor Keyset For
	Select Product_Code, QuantityReceived, IsNull(Free, 0), PurchasePrice, Batch_Code
	From Batch_Products Where StockTransferID = @StkTfrID
	Open UndoOpening
	Fetch From UndoOpening Into @ItemCode, @Quantity, @Free, @Price, @BATCH_CODE
	While @@Fetch_Status = 0
	Begin
		Set @Quantity = 0 - @Quantity
		--Taxsuffered updation in opening details table	
		If Exists (Select * From SysColumns Where Name = 'PTS' And ID = (Select ID From Sysobjects Where Name = 'Items'))  
			exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @ItemCode , @BATCH_CODE , 1  
		Else
			exec Sp_Update_Opening_TaxSuffered_Percentage_Fmcg @OpeningDate , @ItemCode , @BATCH_CODE , 1  			

		exec sp_update_opening_stock @ItemCode, @OpeningDate, @Quantity, @Free, @Price
		Fetch Next From UndoOpening Into @ItemCode, @Quantity, @Free, @Price, @BATCH_CODE
	End
	Close UndoOpening
	DeAllocate UndoOpening
	Update Batch_Products Set Quantity = 0 Where StockTransferID = @StkTfrID
	Select 1
End
Finish:



