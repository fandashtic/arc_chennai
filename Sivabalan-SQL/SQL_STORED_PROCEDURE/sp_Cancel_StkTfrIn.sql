CREATE Procedure sp_Cancel_StkTfrIn ( @StkTfrID Int,  
     @OpeningDate Datetime,  
     @Remarks nvarchar(255),  
     @LogonUser nvarchar(50))  
As  
Declare @BatchCode Int  
Declare @ItemCode nvarchar(20)  
Declare @Quantity Decimal(18,6)  
Declare @Price Decimal(18,6)  
Declare @Free Int  
  
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
 Update StockTransferInAbstract Set Status = Status | 64, Remarks = @Remarks,  
 CancelUser = @LogonUser,CancellationDate=GETDATE()  
 Where DocSerial = @StkTfrID  
  
 Declare UndoOpening Cursor Keyset For  
 Select Batch_Code, Product_Code, QuantityReceived, IsNull(Free, 0), PurchasePrice  
 From Batch_Products Where StockTransferID = @StkTfrID  
 Open UndoOpening  
 Fetch From UndoOpening Into @BatchCode, @ItemCode, @Quantity, @Free, @Price  
 While @@Fetch_Status = 0  
 Begin  
  --Updating TaxSuff Percentage in OpeningDetails  
  If Exists (Select * From SysColumns Where Name = 'PTS' And ID = (Select ID From Sysobjects Where Name = 'Items'))    
   Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate, @ITEMCODE, @BATCHCODE, 1  
  Else  
   Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @ITEMCODE, @BATCHCODE, 1  
    
  Set @Quantity = 0 - @Quantity  
  exec sp_update_opening_stock @ItemCode, @OpeningDate, @Quantity, @Free, @Price, 0, 0, @BATCHCODE
  Fetch Next From UndoOpening Into @BatchCode, @ItemCode, @Quantity, @Free, @Price  
 End  
 Close UndoOpening  
 DeAllocate UndoOpening  
  
 Update Batch_Products Set Quantity = 0 Where StockTransferID = @StkTfrID  
 Select 1  
End  
Finish:  
