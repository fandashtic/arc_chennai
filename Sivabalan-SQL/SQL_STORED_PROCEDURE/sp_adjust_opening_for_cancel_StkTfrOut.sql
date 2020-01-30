CREATE PROCEDURE sp_adjust_opening_for_cancel_StkTfrOut(@DocSerial int, @StkTrfOutDate datetime)  
AS  
DECLARE @Batch_Code  int  
DECLARE @Quantity Decimal(18,6)  
DECLARE @PurchasePrice Decimal(18,6)  
DECLARE @Product_Code nvarchar(15)  
DECLARE @FREE int  
  
DECLARE GetReturned CURSOR STATIC FOR  
Select Product_Code, Batch_Code, Quantity, Rate from StockTransferOutDetail where DocSerial = @DocSerial  
OPEN GetReturned
   
FETCH FROM GetReturned INTO  @Product_Code, @Batch_Code , @Quantity, @PurchasePrice  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	Select @FREE = ISNULL(Free, 0) From Batch_Products Where Batch_Code = @Batch_Code  
	exec sp_update_opening_stock @Product_Code, @StkTrfOutDate, @Quantity, @FREE, @PurchasePrice, 0, 0  
	FETCH NEXT FROM GetReturned INTO @Product_Code, @Batch_Code , @Quantity, @PurchasePrice  
END
CLOSE GetReturned  
DEALLOCATE GetReturned 
