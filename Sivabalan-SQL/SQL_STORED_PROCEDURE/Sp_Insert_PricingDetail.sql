
Create Procedure Sp_Insert_PricingDetail (
	@PricingSerial Int, 
	@SegmentID Int, 
	@SalePrice Decimal(18,6), 
	@PaymentMode Int = -1)  
As  
Declare @SegmentSerial Int  
Set @SegmentSerial = 0  
--To get the SegmentSerial   
Select @SegmentSerial = IsNull(SegmentSerial,0) From PricingSegmentDetail Where PricingSerial = @PricingSerial And SegmentID= @SegmentID  
IF @SegmentSerial = 0  
BEGIN  
   Insert into PricingSegmentDetail(PricingSerial, SegmentID) Values (@PricingSerial, @SegmentID)  
   SELECT @SegmentSerial = @@Identity  
END  
IF @PaymentMode = -1
	Insert into PricingPaymentDetail(SegmentSerial, PaymentMode, SalePrice)
	Select @SegmentSerial as SegemtnSerial, Mode as PaymentMode, @SalePrice as SalePrice From PaymentTerm Where Active = 1 
ELSE
	Insert into PricingPaymentDetail(SegmentSerial, PaymentMode, SalePrice) Values (@SegmentSerial, @PaymentMode, @SalePrice)


