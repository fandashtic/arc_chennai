CREATE PROCEDURE sp_consolidate_dispatch_detail(@DispatchID INT, 
		@ProductCode NVARCHAR(15),
		@Quantity Decimal(18,6), 
		@BatchCode INT,
		@SalePrice Decimal(18,6),
		@FlagWord Int)
AS
INSERT INTO 
DispatchDetail  (DispatchID, 
		Product_Code, 
		Quantity, 
		Batch_Code, 
		SalePrice,
		FlagWord)
VALUES		
		(@DispatchID, 
		@ProductCode, 
		@Quantity, 
		@BatchCode, 
		@SalePrice,
		@FlagWord)
