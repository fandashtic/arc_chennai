CREATE Procedure Sp_Get_ItemPrice(  
 @CustCode as nVarchar(50), @PaymentMode as Int, @ItemCode as Nvarchar(25), @Quantity as Int, @QuotationID as Int = 0)  
As  
DECLARE @PARENTIDLIST  nVarchar(1000)  
Declare @SEGMENTID Int  
Declare @QtMargin as Decimal(18,6)
Declare @QtMarginPer as Decimal(18,6)
Set @QtMarginPer = 1
Select @SEGMENTID = SegmentID From Customer Where CustomerID=@CustCode  
Select @PARENTIDLIST =dbo.fn_Get_Parent_CustomerSegments(@SEGMENTID)  
Select @QtMargin = MarginPercentage from QuotationItems Where QuotationID = @QuotationId  and MarginON = 4
IF @QtMargin <> 0
  BEGIN 
    SET @QtMarginPer = @QtMargin / 100
  END

Select Case When @QtMargin <> 0 Then PPD.SalePrice - (PPD.SalePrice * @QtMarginPer)
	Else PPD.SalePrice End SalePrice
From PricingAbstract PA, PricingSegmentDetail PSD, PricingPaymentDetail PPD  
Where PA.ItemCode = @ItemCode   
 And @Quantity between PA.SlabStart and PA.SlabEnd  
 And PA.CustType = 1  
 And PA.PricingSerial = PSD.PricingSerial  
 And PSD.SegmentID in (Select * from dbo.sp_SplitIn2Rows(@PARENTIDLIST,N','))  
 And PPD.PaymentMode = @PaymentMode  
 And PSD.SegmentSerial = PPD.SegmentSerial  
Union  
Select Case When @QtMargin <> 0 Then PPD.SalePrice - (PPD.SalePrice * @QtMarginPer)
	Else PPD.SalePrice End SalePrice
From PricingAbstract PA, PricingSegmentDetail PSD, Customer C, PricingPaymentDetail PPD  
Where PA.ItemCode = @ItemCode   
 And @Quantity between PA.SlabStart and PA.SlabEnd  
 And PA.CustType = 2  
 And PA.PricingSerial = PSD.PricingSerial  
 And C.ChannelType = PSD.SegmentID  
 And C.CustomerId = @CustCode  
 And PPD.PaymentMode = @PaymentMode  
 And PSD.SegmentSerial = PPD.SegmentSerial  
  


