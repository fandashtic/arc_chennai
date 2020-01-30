CREATE PROCEDURE sp_create_purchaseorderdetail(@PONumber INT, 
		@ProductCode NVARCHAR(15), 
		@Quantity Decimal(18,6), 
		@PurchasePrice Decimal(18,6),
		@Serial int =0)
AS
INSERT INTO 
PODetail  	(PONumber, 
		Product_Code, 
		Quantity, 
		Pending,
		PurchasePrice,
		Serial)
VALUES		
		(@PONumber, 
		@ProductCode, 
		@Quantity, 
		@Quantity, 
		@PurchasePrice,
		@Serial)


