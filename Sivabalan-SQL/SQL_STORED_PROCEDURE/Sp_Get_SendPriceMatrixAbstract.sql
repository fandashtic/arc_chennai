
Create Procedure Sp_Get_SendPriceMatrixAbstract(@ITEMS_LIST nVarchar(4000))  
AS  
Declare @DELIMETER as Char(1)      
Set @DELIMETER=Char(15)      
Create Table #tmpItem(ItemCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert InTo #tmpItem select Product_Code From Items Where Product_Code In   
   (Select * from dbo.sp_SplitIn2Rows(@ITEMS_LIST, @DELIMETER))  
  
Select PricingSerial, Alias as Forum_Code, SlabStart as Slab_Start, SlabEnd as Slab_End,  
Case When CustType = 1 Then N'Segment' Else N'Channel' End as Cust_Type     
From    
(    
Select PAbs.PricingSerial, Items.Alias, PAbs.SlabStart, PAbs.SlabEnd, PAbs.CustType    
FROM Items, PricingAbstract PAbs  
Where PAbs.CustType = 1 And Items.Product_Code = Pabs.ItemCode And     
Items.Product_code in (Select * From #tmpItem)    
Union All    
Select PAbs.PricingSerial, Items.Alias, PAbs.SlabStart, PAbs.SlabEnd, PAbs.CustType    
FROM Items, PricingAbstract PAbs  
Where PAbs.CustType = 2 And Items.Product_Code = Pabs.ItemCode And     
Items.Product_code in (Select * From #tmpItem)    
) A    
Order By PricingSerial  
Drop Table #tmpItem  
  
