Create Function mERP_fn_getInvwiseOutstanding_Chq
(    
	@CustomerId nVarchar(100),    
	@InvoiceId Int,    
	@CollectionId Int,@CollToDate datetime,    
	@CollPaymentModeNo int,    
	@CollDate datetime    
)      
Returns Decimal(18,6)      
As      
Begin      
	 Declare @UnRealisedAmt Decimal(18,6)
     Declare @OutstandingAmt Decimal(18,6)      

	 select @OutstandingAmt = documentvalue - AdjAmount
	 from    
	 (    
		 select DocumentID,documentvalue , sum(AdjAmount) as AdjAmount    
		 from     
		 (    
		 --Excluding Postdated only    
		 select Det.DocumentID,isnull(Det.documentvalue,0) as documentvalue,     
				Isnull(AdjustedAmount,0) + isnull(Adjustment,0) as AdjAmount    
		 from Collections Abst,CollectionDetail Det      
		 where     
			  Det.DocumentID = @InvoiceId        
--                        and Abst.Paymentmode = @CollPaymentModeNo      
			  and Isnull(Abst.Status,0) & 192 = 0      
			  and Abst.CustomerId=@CustomerID       
			  --Dont use dbo.striptimefromdate() on this.Because same date can have more than one collections    
			  and (dbo.striptimefromdate(Abst.DocumentDate) <= dbo.striptimefromdate(@CollDate)  and Det.CollectionId <= @CollectionId)       
			  and Abst.DocumentDate <= @CollToDate    
			  And Abst.Value >= 0     
			  and Abst.DocumentID = Det.CollectionId       
		 union all    
		 --Postdated only    
		 select Det.DocumentID,isnull(Det.documentvalue,0) as documentvalue,     
				Isnull(AdjustedAmount,0) + isnull(Adjustment,0) as AdjAmount    
		 from Collections Abst,CollectionDetail Det      
		 where     
			  Det.DocumentID = @InvoiceId        
--                        and Abst.Paymentmode = @CollPaymentModeNo      
			  and Isnull(Abst.Status,0) & 192 = 0      
			  and Abst.CustomerId=@CustomerID       
			  and (dbo.striptimefromdate(Abst.DocumentDate) < dbo.striptimefromdate(@CollDate)  and Det.CollectionId > @CollectionId)       
			  and Abst.DocumentDate <= @CollToDate    
			  And Abst.Value >= 0     
			  and Abst.DocumentID = Det.CollectionId       
		  ) tmp    
		 group by DocumentID,documentvalue    
	 ) tmp   

	 Set @UnRealisedAmt = 0
	 If (Select isnull(paymentmode,0) from collections where DocumentId = @CollectionID) = 1
	 BEGIN
		Select @UnRealisedAmt = isnull(Sum(C.Value),0) from Collections C, collectionDetail CD Where 
		C.DocumentID = CD. CollectionID And
		C.DocumentID = @CollectionID And 
		Isnull(C.status,0) & 192 = 0 and
		isnull(C.realised,0) Not In (1)
		and (dbo.striptimefromdate(C.DocumentDate) <= dbo.striptimefromdate(@CollDate)  and CD.CollectionId <= @CollectionId)       
		and C.DocumentDate <= @CollToDate    
		And C.Value >= 0
		Set @UnRealisedAmt = @UnRealisedAmt - dbo.mERP_fn_getRealisedBalance_ITC(@CollectionID)
	 END

     Return @OutstandingAmt + @UnRealisedAmt     
End     
