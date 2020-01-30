
Create Procedure Sp_Save_PricingAbstract
(
	@StartSlab Decimal(18,6), 
	@EndSlab Decimal(18,6), 
	@ItemCode nVarchar(15), 
	@CustType Int,
	@SamePrice Int
)  
As  

Begin 
	Insert into PricingAbstract (SlabStart,SlabEnd,CustType,ItemCode,SamePrice) Values (@StartSlab,@EndSlab,@CustType,@ItemCode,@SamePrice)  
	Select @@IDentity  
End  

