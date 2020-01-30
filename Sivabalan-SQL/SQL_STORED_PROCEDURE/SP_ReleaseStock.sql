
CREATE proc SP_ReleaseStock(@ItemCode NVARCHAR(15),@BatchNumber NVARCHAR(255) , @SalePrice Decimal(18,6) , @RequiredQuantity Decimal(18,6) )
AS
declare @BatchCode int 
declare @Quantity Decimal(18,6)
declare @TotalQuantity  Decimal(18,6)

select @TotalQuantity = sum(Quantity)  FROM Batch_Products WHERE Batch_Number = @BatchNumber and saleprice = @SalePrice and Product_Code=@ItemCode
if @TotalQuantity < @RequiredQuantity
GOTO OVERNOUTT

declare ReleaseStocks CURSOR KEYSET FOR
SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products
WHERE Product_Code=@ItemCode and Batch_Number = @BatchNumber and saleprice = @SalePrice
OPEN ReleaseStocks
FETCH FROM ReleaseStocks into @BatchNumber, @BatchCode, @Quantity

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Quantity >= @RequiredQuantity
    BEGIN
        UPDATE Batch_Products set Quantity = Quantity - @RequiredQuantity
        where Batch_Code = @BatchCode
        GOTO OVERNOUT
    END
    ELSE
    BEGIN
	set @RequiredQuantity = @RequiredQuantity - @Quantity	
	UPDATE Batch_Products set Quantity = 0 where Batch_Code = @BatchCode
    END 
    FETCH NEXT FROM ReleaseStocks into @BatchNumber, @BatchCode, @Quantity
END
OVERNOUT:
CLOSE ReleaseStocks
deallocate  ReleaseStocks
OVERNOUTT:


