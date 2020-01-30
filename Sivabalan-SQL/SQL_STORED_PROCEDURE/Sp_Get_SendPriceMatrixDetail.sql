
Create Procedure Sp_Get_SendPriceMatrixDetail(@ITEMS_LIST nVarchar(2000))  
AS  
Declare @DELIMETER as Char(1)    
Set @DELIMETER=Char(15)    
Create Table #tmpItem(ItemCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert InTo #tmpItem select Product_Code From Items Where Product_Code In 
   (Select * from dbo.sp_SplitIn2Rows(@ITEMS_LIST, @DELIMETER))

Select Items.Alias as Forum_Code, PAbs.SlabStart, PAbs.SlabEnd, N'Segment' as CustType,  
CS.SegmentName as CSName, IsNull(PMode.Value,'') as PayMode, PPD.SalePrice  
FROM Items, PaymentTerm PMode, PricingAbstract PAbs, PricingSegmentDetail PSD,   
PricingPaymentDetail PPD, CustomerSegment CS  
Where PAbs.CustType = 1 And   
Items.Product_Code = Pabs.ItemCode And   
PAbs.PricingSerial = PSD.PricingSerial And  
PSD.SegmentSerial = PPD.SegmentSerial And  
CS.SegmentId = PSD.SegmentID And   
PMode.Mode = PPD.PaymentMode And   
Items.Product_code in (Select * From #tmpItem)  
Union All  
Select Items.Alias as Forum_Code, PAbs.SlabStart, PAbs.SlabEnd, N'Channel' as CustType,  
CC.ChannelDesc as CSName, IsNull(PMode.Value,'') as PayMode, PPD.SalePrice  
FROM Items, PaymentTerm PMode, PricingAbstract PAbs, PricingSegmentDetail PSD,   
PricingPaymentDetail PPD, Customer_Channel CC  
Where PAbs.CustType = 2 And   
Items.Product_Code = Pabs.ItemCode And   
PAbs.PricingSerial = PSD.PricingSerial And  
PSD.SegmentSerial = PPD.SegmentSerial And  
CC.ChannelType = PSD.SegmentID And   
PMode.Mode = PPD.PaymentMode And   
Items.Product_code in (Select * From #tmpItem)  
ORDER BY Items.Alias, CustType, PayMode, CSName, SlabStart 

Drop Table #tmpItem

