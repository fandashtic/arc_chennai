
Create Procedure Sp_Select_PricingAbstract(@ItemCode NVarChar(15))
As
Select 
	Slabstart,SlabEnd,CustType,SamePrice
From 
	PricingAbstract 
Where 
	Itemcode=@ItemCode

