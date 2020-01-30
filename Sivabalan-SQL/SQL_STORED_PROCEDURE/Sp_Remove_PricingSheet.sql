
Create Procedure Sp_Remove_PricingSheet(@ItemCode NVarChar(15))
As
Begin

	Delete
	From 
		PricingPaymentDetail 
	Where 
		SegmentSerial In
		(
			Select SegmentSerial
			From PricingAbstract PA,PricingSegmentDetail PSD 
			Where	PA.PricingSerial=PSD.PricingSerial And PA.Itemcode=@ItemCode
			)

	Delete
	From 
		PricingSegmentDetail 
	Where 
		PricingSerial In
		(
			Select PricingSerial 
			From PricingAbstract  
			Where Itemcode=@ItemCode
		)

	Delete
	From 
		PricingAbstract 
	Where 
		Itemcode=@ItemCode
End
	
