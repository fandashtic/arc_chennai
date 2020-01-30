CREATE PROCEDURE sp_consolidate_po_detail(@PONumber INT, 
		@ForumCode nvarchar(15), 
		@Quantity Decimal(18,6), 
		@Pending Decimal(18,6),
		@PurchasePrice Decimal(18,6))
AS
Declare @ProductCode nvarchar(20)
Select @ProductCode = Product_Code From Items Where Alias = @ForumCode
UPDATE PODetail SET Quantity = @Quantity, Pending = @Pending, PurchasePrice = @PurchasePrice
WHERE PONumber = @PONumber AND Product_Code = @ProductCode
IF @@ROWCOUNT = 0 
BEGIN
INSERT INTO 
PODetail  	(PONumber, 
		Product_Code, 
		Quantity, 
		Pending,
		PurchasePrice)
VALUES		
		(@PONumber, 
		@ProductCode, 
		@Quantity, 
		@Pending, 
		@PurchasePrice)
END
