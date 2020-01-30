
CREATE Procedure Sp_Insert_PricingAbstract (@ItemCode nVarchar(15), @StartSlab Decimal(18,6), @EndSlab Decimal(18,6), @CustType Int, @SamePrice Int = 0)        
As        
Begin        
   Insert into PricingAbstract (ItemCode, SlabStart, SlabEnd, CustType, SamePrice) Values (@ItemCode, @StartSlab, @EndSlab, @CustType, @SamePrice)        
   Select @@IDentity        
End  

