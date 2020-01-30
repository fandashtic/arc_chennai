CREATE PROCEDURE sp_cancel_dispatch(@DispatchID int, @DispatchDate datetime)  
AS  
DECLARE @Batch_Code  int  
DECLARE @Quantity Decimal(18,6)  
DECLARE @Product_Code nvarchar(15)  
DECLARE @FREE Decimal(18,6)  
DECLARE @PurchasePrice Decimal(18,6)  
  
DECLARE GetReturnedDispatch CURSOR STATIC FOR  
select Product_Code, Batch_Code, Quantity from DispatchDetail where DispatchID = @DispatchID  
OPEN GetReturnedDispatch  
  
FETCH FROM GetReturnedDispatch INTO  @Product_Code, @Batch_Code , @Quantity   
WHILE @@FETCH_STATUS = 0  
BEGIN  
 Select @FREE = ISNULL(Free, 0), @PurchasePrice = ISNULL(PurchasePrice,0) From Batch_Products Where Batch_Code = @Batch_Code  
 UPDATE batch_products set Quantity = Quantity + @Quantity where Batch_Code = @Batch_Code  
 exec sp_update_opening_stock @Product_Code, @DispatchDate, @Quantity, @FREE, @PurchasePrice  
 FETCH NEXT FROM GetReturnedDispatch INTO @Product_Code, @Batch_Code , @Quantity   
END  
CLOSE GetReturnedDispatch  
DEALLOCATE GetReturnedDispatch  
  


