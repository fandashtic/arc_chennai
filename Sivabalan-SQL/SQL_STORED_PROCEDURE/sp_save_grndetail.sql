CREATE PROCEDURE sp_save_grndetail(@GRNID int, 
				   @PRODUCT_CODE nvarchar(15), 
				   @QUANTITY_RECEIVED Decimal(18,6),
				   @QUANTITY_REJECTED Decimal(18,6),
				   @REASON_REJECTED int,
				   @FREE Decimal(18,6))
AS
INSERT INTO GRNDetail
([GRNID],
[Product_Code],
[QuantityReceived],
[QuantityRejected],
[ReasonRejected],
[FreeQty])
VALUES	(@GRNID, 
	 @PRODUCT_CODE, 
	 @QUANTITY_RECEIVED, 
	 @QUANTITY_REJECTED,
	 @REASON_REJECTED,
	 @FREE)
Exec sp_update_openingdetails_firsttime @PRODUCT_CODE


