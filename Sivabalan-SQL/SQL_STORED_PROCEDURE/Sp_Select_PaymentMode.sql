Create Procedure Sp_Select_PaymentMode(@ItemCode NVarChar(15))
As

Select 
	PaymentMode
From 
	PricingPaymentDetail PPD,PaymentTerm PT
Where 
	PPD.SegmentSerial In
	(
		Select SegmentSerial
		From PricingAbstract PA,PricingSegmentDetail PSD 
		Where	PA.PricingSerial=PSD.PricingSerial And PA.Itemcode=@ItemCode
		)
	And PaymentMode = Mode
Group by
	PaymentMode,Value
Order by
 Value


