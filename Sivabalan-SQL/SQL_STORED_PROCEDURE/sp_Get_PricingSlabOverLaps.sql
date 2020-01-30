CREATE PROCEDURE sp_Get_PricingSlabOverLaps(@ITEM_CODE nVarchar(25), @SLAB_START  Decimal(18,6), @SLAB_END  Decimal(18,6), @CUST_TYPE Int, @SEGMENT_ID Int, @PAYMENT_MODE Int = -1)    
As    
Declare @RETURNVAL as Int     
Set @RETURNVAL = 0     
CREATE TABLE #tmpSLABS(ID Int Identity, PricingSerial Int, SlabStart Numeric(18,6), SlabEnd Numeric(18,6))    
  BEGIN    
    If @PAYMENT_MODE = -1  
      BEGIN    
        INSERT INTO #tmpSLABS    
        SELECT PA.PricingSerial, PA.SlabStart, PA.SlabEnd    
        FROM PricingAbstract PA,  PricingSegmentDetail PSD, PricingPaymentDetail PPD    
        WHERE PA.ItemCode = @ITEM_CODE And PA.CustType = @CUST_TYPE And    
        PA.PricingSerial = PSD.PricingSerial And PSD.SegmentID = @SEGMENT_ID And    
        PSD.SegmentSerial = PPD.SegmentSerial    
        ORDER BY PA.SlabStart    
      END    
    ELSE    
      BEGIN    
        INSERT INTO #tmpSLABS    
        SELECT PA.PricingSerial, PA.SlabStart, PA.SlabEnd    
        FROM PricingAbstract PA,  PricingSegmentDetail PSD, PricingPaymentDetail PPD    
        WHERE PA.ItemCode = @ITEM_CODE And PA.CustType = @CUST_TYPE And    
        PA.PricingSerial = PSD.PricingSerial And PSD.SegmentID = @SEGMENT_ID And    
        PSD.SegmentSerial = PPD.SegmentSerial And PPD.PaymentMode = @PAYMENT_MODE    
        ORDER BY PA.SlabStart    
      END    
    IF Exists(Select PricingSerial From #tmpSlabs Where (@SLAB_START Between SlabStart And SlabEnd) OR (@SLAB_END Between SlabStart And SlabEnd))    
      BEGIN
       Set @RETURNVAL = 1    
       Goto EXITPROC    
      END
    IF Exists(Select PricingSerial From #tmpSlabs Where (SlabStart Between @SLAB_START And @SLAB_END) OR (SlabEnd Between @SLAB_START And @SLAB_END))    
      BEGIN    
        Set @RETURNVAL = 1    
        Goto EXITPROC    
      END
  END    
EXITPROC:    
Select @RETURNVAL    
Drop Table #tmpSLABS  
  


