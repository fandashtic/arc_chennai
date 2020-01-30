
Create Procedure Sp_Get_RecPriceMatrix_PaymodeExcpList(@FORUM_CODE as nvarchar(50))
As
Select Distinct IsNull(PaymentMode,'')
from PricingPaymentDetailReceived PPD,  PricingSegmentDetailReceived PSD, PricingAbstractReceived PAR 
Where PAR.ItemCode = @FORUM_CODE  And 
PAR.PricingSerial = PSD.PricingSerial And 
PSD.SegmentSerial = PPD.SegmentSerial And 
IsNull(PPD.PaymentMode,'') Not in (Select Value From PaymentTerm)

