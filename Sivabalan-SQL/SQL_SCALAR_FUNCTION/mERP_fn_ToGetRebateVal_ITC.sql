CREATE Function mERP_fn_ToGetRebateVal_ITC(
	@RebateQV Decimal(18, 6), 
	@Type Int, 
	@SlabID Int 
	)    
Returns Decimal(18, 6)
As    
Begin    
Declare @ItemFree Int
Declare @RebateVal Decimal(18, 6)

Select @ItemFree = (Case Max(SlabType) When 1 Then 0 When 2 Then 0 Else 1 End) From tbl_mERP_SchemeSlabDetail Where SlabID = @SlabID  

If @ItemFree = 1 And @Type = 0 
Begin
	Set @RebateVal = 0  
End
Else
Begin
	Set @RebateVal = @RebateQV  
End


Return @RebateVal 
End
