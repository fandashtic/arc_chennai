
Create Procedure Sp_Delete_PricingMatrixImport(@ITEM_CODE nvarchar(15))
As
   BEGIN
	DELETE FROM PricingPaymentDetail Where SegmentSerial in (
	Select SegmentSerial FROM PricingSegmentDetail	Where PricingSerial in (
	Select PricingSerial From PricingAbstract Where ItemCode=@ITEM_CODE))

	DELETE FROM PricingSegmentDetail 
	Where PricingSerial in (Select PricingSerial From PricingAbstract Where ItemCode=@ITEM_CODE)

	DELETE FROM PricingAbstract Where ItemCode=@ITEM_CODE
   END

