Create Function Fn_GetLeastLevelSKU(@Product Nvarchar(4000),@Level Int)
Returns 
	@Items Table (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
As
Begin
	If @Level = 2
	Begin
		If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
		Begin	
			Insert Into @Items (Product_Code)
			select Distinct I.Product_Code
			From items I , ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC2.Category_Name = @Product
		End
		Else
		Begin
			Insert Into @Items (Product_Code)
			Select Distinct SystemSKU from OCGItemMaster O,Items I
			Where O.Division = @Product 
			And I.Product_Code = O.SystemSKU
			And O.Exclusion = 0
		End
	End
	Else If @Level = 3
	Begin
		If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
		Begin	
			Insert Into @Items (Product_Code)
			select Distinct  I.Product_Code
			From items I , ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC3.Category_Name = @Product
		End
		Else
		Begin
			Insert Into @Items (Product_Code)
			Select Distinct SystemSKU from OCGItemMaster O,Items I
			Where O.SubCategory = @Product 
			And I.Product_Code = O.SystemSKU
			And O.Exclusion = 0
		End
	End
	Else If @Level = 4
	Begin
		If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 0
		Begin
			Insert Into @Items (Product_Code)	
			select Distinct  I.Product_Code
			From items I , ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 where
			IC4.categoryid = i.categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
			and IC4.Category_Name = @Product
		End
		Else
		Begin
			Insert Into @Items (Product_Code)
			Select Distinct SystemSKU from OCGItemMaster O,Items I
			Where O.MarketSKU = @Product 
			And I.Product_Code = O.SystemSKU
			And O.Exclusion = 0
		End
	End
	Else If @Level = 5
	Begin
		Insert Into @Items (Product_Code)	
		select @Product
	End

Return   
End  
