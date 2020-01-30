Create Procedure Sp_Select_PricingSegmentDetail(@ItemCode NVarChar(15),@CustType Int)
As

If @CustType = 1
	Select   
	  PSD.SegmentId
	From   
	 PricingSegmentDetail PSD,CustomerSegment  
	Where   
		PSD.SegmentId=CustomerSegment.SegmentId And 
	 PSD.PricingSerial In  
	 (  
	  Select PricingSerial   
	  From PricingAbstract    
	  Where Itemcode = @ItemCode
	 )  
	Group by
		PSD.SegmentId,CustomerSegment.SegmentName
	Order by
		CustomerSegment.SegmentName
Else
	Select   
  PSD.SegmentId
	From   
	 PricingSegmentDetail PSD,Customer_Channel CC
	Where   
		PSD.SegmentId=CC.ChannelType And 
	 PSD.PricingSerial In  
	 (  
	  Select PricingSerial   
	  From PricingAbstract    
	  Where Itemcode = @ItemCode
	 )  
	Group by
		PSD.SegmentId,CC.ChannelDesc
	Order by
		CC.ChannelDesc



