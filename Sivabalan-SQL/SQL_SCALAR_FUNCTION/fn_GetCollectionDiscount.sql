
Create Function fn_GetCollectionDiscount(@CollectionID int)  
Returns Decimal(18,6)   
As   
Begin  
	Declare @ColDiscount as Decimal(18,6)  

	Select @ColDiscount = Sum((CollectionDetail.Discount/100) * (CollectionDetail.DocumentValue)) From CollectionDetail
	Where CollectionID = @CollectionID 
	Return (Select IsNull(@ColDiscount,0))    
End  
