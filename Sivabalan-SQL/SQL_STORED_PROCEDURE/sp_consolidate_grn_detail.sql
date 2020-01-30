CREATE PROCEDURE sp_consolidate_grn_detail(@GRNID INT, 
		@ProductCode NVARCHAR(15),
		@QuantityReceived Decimal(18,6), 
		@QuantityRejected Decimal(18,6), 
		@ReasonRejected int,
		@FreeQty Decimal(18,6))
AS
INSERT INTO 
GRNDetail  	(GRNID, 
		Product_Code, 
		QuantityReceived, 
		QuantityRejected, 
		ReasonRejected,
		FreeQty)
VALUES		
		(@GRNID, 
		@ProductCode, 
		@QuantityReceived, 
		@QuantityRejected, 
		@ReasonRejected,
		@FreeQty)
