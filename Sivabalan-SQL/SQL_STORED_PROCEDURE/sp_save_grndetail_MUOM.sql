CREATE PROCEDURE sp_save_grndetail_MUOM(@GRNID int, 
				   @PRODUCT_CODE nvarchar(15), 
				   @QUANTITY_RECEIVED Decimal(18,6),
				   @QUANTITY_REJECTED Decimal(18,6),
				   @REASON_REJECTED int,
				   @FREE Decimal(18,6),
				   @UOM int = 0,
				   @UOMQty Decimal(18,6) = 0,
				   @UOMRejection Decimal(18,6) = 0,
				   @DiscPer Decimal(18,6) = 0,
				   @DiscPerUnit Decimal(18,6) = 0,
				   @InvDiscPerc Decimal(18,6) = 0,
				   @InvDiscPerUnit Decimal(18,6) = 0,
				   @InvDiscAmt Decimal(18,6) = 0,
				   @OtherDiscPerc Decimal(18,6) = 0,
				   @OtherDiscPerUnit Decimal(18,6) = 0,
				   @OtherDiscAmt Decimal(18,6) = 0,
				   @DiscType Int = 0,
				  @TOQ int = 0)
AS
BEGIN

INSERT INTO GRNDetail
	([GRNID],
	 [Product_Code],
	 [QuantityReceived],
	 [QuantityRejected],
	 [ReasonRejected],
	 [FreeQty],
	 [UOM],
	 [UOMQty],
	 [UOMRejection],
	 [DiscPer],
	 [DiscPerUnit],
	 [InvDiscPer],
	 [InvDiscPerUnit],
	 [InvDiscAmt],
	 [OtherDiscPer],
	 [OtherDiscPerUnit],
	 [OtherDiscAmt],
	 [DiscType],[TOQ])
VALUES	(@GRNID, 
	 @PRODUCT_CODE, 
	 @QUANTITY_RECEIVED, 
	 @QUANTITY_REJECTED,
	 @REASON_REJECTED,
	 @FREE,
	 @UOM,
	 @UOMQty,
	 @UOMRejection,@DiscPer,@DiscPerUnit,
	 @InvDiscPerc,
	 @InvDiscPerUnit,
	 @InvDiscAmt,
	 @OtherDiscPerc,
	 @OtherDiscPerUnit,
	 @OtherDiscAmt,
	 @DiscType,@TOQ
	 )

Exec sp_update_openingdetails_firsttime @PRODUCT_CODE
END
