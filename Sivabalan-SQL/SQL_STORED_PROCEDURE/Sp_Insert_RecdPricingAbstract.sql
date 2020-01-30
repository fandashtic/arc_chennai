
Create Procedure Sp_Insert_RecdPricingAbstract(  
  @ItemCode nVarchar(15),   
  @StartSlab Decimal(18,6),   
  @EndSlab Decimal(18,6),   
  @CustType Int,  
  @FLAG Int,   
  @PartyCode nVarchar(40),
  @SERIAL Int)    
As
Begin
   Insert into PricingAbstractReceived (ItemCode, SlabStart, SlabEnd, CustType, Flag, PartyCode, Serial ) Values (@ItemCode, @StartSlab, @EndSlab, @CustType, @FLAG, @PartyCode, @SERIAL)    
   Select @@IDentity
End

