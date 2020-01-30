
Create Procedure Sp_Select_PricingPaymentDetail(@ItemCode NVarChar(15),@CustType Int)  
As  

If @CustType = 1
	Select 
		PPD.SalePrice,PA.SlabStart,PA.SlabEnd,CS.SegmentName,PT.Value
	From 
		PricingPaymentDetail PPD,PricingSegmentDetail PSD,PricingAbstract PA,CustomerSegment CS,PaymentTerm PT
	Where 
	 PA.ItemCode = @ItemCode
		And PA.PricingSerial = PSD.PricingSerial
		And PSD.SegmentSerial = PPD.SegmentSerial 
		And PSD.SegmentID = CS.SegmentID 
		And PPD.PaymentMode = PT.Mode
Else
	Select 
		PPD.SalePrice,PA.SlabStart,PA.SlabEnd,CC.ChannelDesc,PT.Value
	From 
		PricingPaymentDetail PPD,PricingSegmentDetail PSD,PricingAbstract PA,Customer_Channel CC,PaymentTerm PT
	Where 
	 PA.ItemCode = @ItemCode
		And PA.PricingSerial = PSD.PricingSerial
		And PSD.SegmentSerial = PPD.SegmentSerial 
		And PSD.SegmentID = CC.ChannelType
		And PPD.PaymentMode = PT.Mode

