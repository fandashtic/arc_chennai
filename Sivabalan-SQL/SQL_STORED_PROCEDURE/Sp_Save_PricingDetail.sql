
Create Procedure Sp_Save_PricingDetail
(
	@PricingSerial Int, 
	@SegmentID Int, 
	@SalePrice Decimal(18,6), 
	@PaymentMode Int = 0
)
As
Declare @SegmentSerial Int
Set @SegmentSerial = 0

Select @SegmentSerial = IsNull(SegmentSerial,0)
From PricingSegmentDetail
Where PricingSerial = @PricingSerial And SegmentID= @SegmentID

IF @SegmentSerial = 0
	BEGIN
	 BEGIN TRAN	
	  Insert into PricingSegmentDetail(PricingSerial, SegmentID) Values (@PricingSerial, @SegmentID)
	 COMMIT TRAN
	 SELECT @SegmentSerial = @@Identity
	END

Insert Into PricingPaymentDetail(SegmentSerial, PaymentMode, SalePrice) Values (@SegmentSerial, @PaymentMode, @SalePrice)

