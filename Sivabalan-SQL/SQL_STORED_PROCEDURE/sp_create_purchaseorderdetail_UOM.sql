CREATE PROCEDURE sp_create_purchaseorderdetail_UOM(@PONumber INT, 
						@ProductCode NVARCHAR(15), 
						@Quantity Decimal(18,6), 
						@PurchasePrice Decimal(18,6),
						@UOMID INT,
						@UOMQty Decimal(18,6),
						@UOMPrice Decimal(18,6),
						@Serial int =0)
AS
INSERT INTO PODetail  	
		(PONumber, 
		Product_Code, 
		Quantity, 
		Pending,
		PurchasePrice,
		UOM,
		UOMQty,
		UOMPrice,
		Serial)
VALUES		
		(@PONumber, 
		@ProductCode, 
		@Quantity, 
		@Quantity, 
		@PurchasePrice,
		@UOMID,
		@UOMQty,
		@UOMPrice,
		@Serial)


