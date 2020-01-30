Create Function dbo.Fn_GetProductCategorys(@Product_Code Nvarchar(255),@Level Int)
Returns Nvarchar(Max)
As
Begin
Declare @String as Nvarchar(Max)
Declare @OCGFlag as Int
Set @OCGFlag = (Select isnull(Flag,0) From Tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS')
If Isnull(@OCGFlag,0) = 0
Begin
	If @Level = 2
	Begin
		Set @String = (Select Top 1 IC2.Category_Name
			from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = GR.Division
			And I.Product_Code = @Product_Code)
	End
	Else If @Level = 3
	Begin
		Set @String = (Select Top 1 IC3.Category_Name
			from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = GR.Division
			And I.Product_Code = @Product_Code)
	End
	Else If @Level = 4
	Begin
		Set @String = (Select Top 1 IC4.Category_Name
			from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = GR.Division
			And I.Product_Code = @Product_Code)
	End
	Else If @Level = 1
	Begin
		Set @String = (Select Top 1 GR.CategoryGroup
			from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = GR.Division
			And I.Product_Code = @Product_Code)
	End
End
Else
Begin
Set @String = (Select (Case 
	When @Level = 1 then GroupName
	When @Level = 2 then Division
	When @Level = 3 then SubCategory
	When @Level = 4 then MarketSKU End)
	From OCGItemMaster Where SystemSKU = @Product_Code
	And Isnull(Exclusion,0) = 0) 
End
Return @String
End
