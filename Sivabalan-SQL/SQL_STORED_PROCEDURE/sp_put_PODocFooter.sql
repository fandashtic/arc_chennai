

CREATE PROCEDURE [sp_put_PODocFooter]
	(@PONumber 	[int],
	 @Product_Code 	[nvarchar](15),
	 @Quantity 	Decimal(18,6),
	 @PurchasePrice 	Decimal(18,6))

AS 
	BEGIN
	INSERT INTO [PODetailReceived] 
	 ( [PONumber],
	 [Product_Code],
	 [Quantity],
	 [PurchasePrice]) 
 
	VALUES 
	( @PONumber,
	 @Product_Code,
	 @Quantity,
	 @PurchasePrice)
	END

