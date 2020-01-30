
Create Procedure Sp_Get_PricingSerial(
		@ItemCode nVarchar(15), 
		@StartSlab Decimal(18,6), 
		@EndSlab Decimal(18,6), 
		@CustType Int)
As
Begin
   Select PricingSerial From PricingAbstract
   Where ItemCode= @ItemCode And SlabStart = @StartSlab and SlabEnd = @EndSlab and CustType = @CustType
End

