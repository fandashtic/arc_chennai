CREATE Procedure sp_Cancel_PurchaseReturn (@DocSerial int, @Opening_Date datetime = Null, @UserName nvarchar(100), @CancelDate Datetime)  
As  
Declare @BatchCode int  
Declare @ItemCode nvarchar(50)  
Declare @Quantity Decimal(18,6)  
Declare @Rate Decimal(18,6)  
Declare @Free Int  

Declare CancelDoc Cursor Static For  
Select AdjustmentReturnDetail.BatchCode, AdjustmentReturnDetail.Quantity, Batch_Products.PurchasePrice, AdjustmentReturnDetail.Product_Code 
From AdjustmentReturnDetail, Batch_Products Where AdjustmentID = @DocSerial and Batch_Products.Batch_Code = AdjustmentReturnDetail.BatchCode  
Open CancelDoc  
Fetch From CancelDoc InTo @BatchCode, @Quantity, @Rate, @ItemCode  
While @@Fetch_Status = 0  
Begin  
	Update Batch_Products Set Quantity = Quantity + @Quantity   
		Where Batch_Code = @BatchCode  
	Select @Free = ISNULL(Free, 0) From Batch_Products Where Batch_Code = @BatchCode  
	exec sp_update_opening_Stock @ItemCode, @Opening_Date, @Quantity, @Free, @Rate, 0 , 0,  @BatchCode
	Fetch Next From CancelDoc InTo @BatchCode, @Quantity, @Rate, @ItemCode  
End  
Update AdjustmentReturnAbstract Set Status = IsNull(Status, 0) | 192, Balance = 0 , CancelUser = @UserName, CancelDate = @CancelDate
Where AdjustmentID = @DocSerial  

Close CancelDoc  
DeAllocate CancelDoc  
  
