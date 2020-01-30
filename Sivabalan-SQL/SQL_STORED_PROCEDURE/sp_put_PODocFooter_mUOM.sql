
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE PROCEDURE [sp_put_PODocFooter_mUOM]
	(@PONumber 	[int],
	 @Product_Code 	[nvarchar](15),
	 @Quantity 	Decimal(18,6),
	 @PurchasePrice 	Decimal(18,6),
	 @UOM nvarchar(50),
	 @UOMQty Decimal(18,6),
 	 @UOMPrice Decimal(18,6) )
AS 
	BEGIN
	INSERT INTO [PODetailReceived] 
	 ( [PONumber],
	 [Product_Code],
	 [Quantity],
	 [PurchasePrice],
	 [UOM],
	 [UOMQty],
 	 [UOMPrice] ) 
 
	VALUES 
	( @PONumber,
	 @Product_Code,
	 @Quantity,
	 @PurchasePrice,
	 @UOM ,
	 @UOMQty ,
 	 @UOMPrice)
	END





