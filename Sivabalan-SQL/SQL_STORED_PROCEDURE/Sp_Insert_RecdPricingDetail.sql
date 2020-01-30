
Create Procedure Sp_Insert_RecdPricingDetail(
		@PricingSerial Int, 
		@SegmentName nVarchar(255), 
		@SalePrice Decimal(18,6), 
		@PaymentMode nVarchar(25) = NULL)
As
Declare @SegmentSerial Int
Set @SegmentSerial = 0
--To get the SegmentSerial 
Select @SegmentSerial = IsNull(SegmentSerial,0) From PricingSegmentDetailReceived 
Where PricingSerial = @PricingSerial And SegmentName= @SegmentName 
IF @SegmentSerial = 0
BEGIN
   Insert into PricingSegmentDetailReceived(PricingSerial, SegmentName) Values (@PricingSerial, @SegmentName)
   SELECT @SegmentSerial = @@Identity
END

Insert into PricingPaymentDetailReceived(SegmentSerial, PaymentMode, SalePrice) Values (@SegmentSerial, @PaymentMode, @SalePrice)


