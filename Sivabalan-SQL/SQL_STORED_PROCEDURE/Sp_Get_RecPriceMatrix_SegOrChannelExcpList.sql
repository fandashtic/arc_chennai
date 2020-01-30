CREATE Procedure Sp_Get_RecPriceMatrix_SegOrChannelExcpList(@FORUM_CODE as nvarchar(50), @SERIAL as Int)  
As  
DECLARE @CUSTTYPE int   
Select @CUSTTYPE = CustType From PricingAbstractReceived Where ItemCode = @FORUM_CODE  
IF @CUSTTYPE = 1   
 Select Distinct PAR.CustType, IsNull(PSD.SegmentName,'')  
 from PricingPaymentDetailReceived PPD,  PricingSegmentDetailReceived PSD, PricingAbstractReceived PAR   
 Where PAR.ItemCode = @FORUM_CODE  And   
 PAR.PricingSerial = PSD.PricingSerial And   
 PSD.SegmentSerial = PPD.SegmentSerial And   
 PAR.Serial = @SERIAL AND
 IsNull(PSD.SegmentName,'') Not in (Select SegmentName From CustomerSegment)  
ELSE   
 Select Distinct PAR.CustType, IsNull(PSD.SegmentName,'')  
 from PricingPaymentDetailReceived PPD,  PricingSegmentDetailReceived PSD, PricingAbstractReceived PAR   
 Where PAR.ItemCode = @FORUM_CODE  And   
 PAR.PricingSerial = PSD.PricingSerial And   
 PSD.SegmentSerial = PPD.SegmentSerial And   
 PAR.Serial = @SERIAL AND
 IsNull(PSD.SegmentName,'') Not in   
 (Select ChannelDesc From Customer_Channel)  
  
  


