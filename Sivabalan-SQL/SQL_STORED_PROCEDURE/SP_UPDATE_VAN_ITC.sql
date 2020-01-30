
CREATE PROC SP_UPDATE_VAN_ITC
	(@VAN NVARCHAR(50),
	 @VANNO NVARCHAR(50),
	 @ACTIVE INT,
	 @READY_STOCK_SALES_VAN INT)
AS
UPDATE VAN 
SET VAN_NUMBER = @VANNO, Active = @ACTIVE, ReadyStockSalesVAN =  @READY_STOCK_SALES_VAN
WHERE VAN = @VAN

