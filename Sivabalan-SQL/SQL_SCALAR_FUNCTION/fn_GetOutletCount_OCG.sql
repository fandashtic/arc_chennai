Create Function  [dbo].[fn_GetOutletCount_OCG](@SmanID As Integer,@CatName As nVarchar(250),@CatGrp as nVarchar(100)= '',@catType as nVarchar(100) = 'Regular')
Returns Int
As
Begin
	Declare @cnt as Int
	Declare @lvl as Int
	Declare @tmpSubCat Table(CatID  Int) 
	If @SmanID = '' And @CatName = '' And @CatGrp <> ''
	Begin	
		
		If @catType = 'Regular'
		Begin
			--Inserts All Subcategory under the category group.
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From ItemCategories Where 
			Category_Name In(Select Division From tblCGDivMapping 	Where CategoryGroup  = @CatGrp))
			And Active = 1

			--Inserts All Division
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where 
			Category_Name In(Select Division From tblCGDivMapping Where CategoryGroup  = @CatGrp)
			And Active = 1
		
		End
		Else
		Begin
			--Inserts All Subcategory under the category group.
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From ItemCategories Where 
			Category_Name In(Select Distinct Division From OCGItemMaster Where GroupName = @CatGrp And Exclusion = 0))
			And Active = 1

			--Inserts All Division
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where 
			Category_Name In(Select Distinct Division From OCGItemMaster Where GroupName = @CatGrp And Exclusion = 0)
			And Active = 1
		End

		Select 
			@cnt = Count(Distinct CP.Customerid) 
		From
			 CustomerProductCategory CP,Customer C--,Beat_Salesman BT
		Where 
			C.Active = 1
			And C.CustomerID = CP.CustomerID
			--And BT.CustomerID = CP.CustomerID 
			--And isNull(BT.SalesmanID,0) <> 0
			--And isNull(BT.BeatID,0) <> 0
			And CP.CategoryID In (Select CatID From @tmpSubCat )
			And CP.Active = 1
			And C.CustomerCategory <> 5

		
		 
	End
	Else if @SmanID <> ''
	Begin
		select @lvl = level from ItemCategories where Category_Name = @CatName
		
		if @lvl = 2
			begin
				--Inserts All Subcategory under the category group.
				Insert Into @tmpSubCat
				Select CategoryID From ItemCategories Where 
				ParentID in (Select categoryid from ItemCategories where category_name = @CatName)
				And Active = 1
				
				--Inserts All Division
				Insert Into @tmpSubCat
				Select categoryid from ItemCategories where category_name = @CatName
				And Active = 1
			end
			else if @lvl = 3
			Begin
				--Inserts All Subcategory under the category group.
				Insert Into @tmpSubCat
				Select categoryid from ItemCategories where category_name = @CatName 
				And Active = 1
				
				--Inserts All Division
				Insert Into @tmpSubCat
				Select ParentID from ItemCategories where category_name = @CatName 
				And Active = 1
			End
		
		Select
			 @cnt = Count(Distinct CP.Customerid) 
		From
			 CustomerProductCategory CP,Customer C ,Beat_Salesman BT,Itemcategories IC 
		Where 
			C.Active = 1
			And C.CustomerID = CP.CustomerID
			And BT.CustomerID = CP.CustomerID 
			And BT.SalesmanID = @SmanID
			And isNull(BT.SalesmanID,0) <> 0
			And isNull(BT.BeatID,0) <> 0
			And CP.CategoryID In (Select CatID From @tmpSubCat)
			And CP.Active = 1
			And C.CustomerCategory <> 5
	End
	Else
	Begin
		select @lvl = level from ItemCategories where Category_Name = @CatName
		If @lvl = 2
		Begin
			--Inserts All Subcategory under the category group.
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where 
			Parentid In(Select CategoryID from ItemCategories where Category_Name = @CatName)
			And Active = 1

		
			--Inserts All Division	
			Insert Into @tmpSubCat
			Select categoryid from ItemCategories where category_name = @CatName
			And Active = 1
		End
		Else if @lvl = 3
		Begin
			--Inserts All Subcategory under the category group.
			Insert Into @tmpSubCat
			Select categoryid from ItemCategories where category_name = @CatName 
			And Active = 1
			
			--Inserts All Division
			Insert Into @tmpSubCat
			Select ParentID from ItemCategories where category_name = @CatName 
			And Active = 1
		End

		Select 
			@cnt = Count(Distinct CP.Customerid) 
		From 
			CustomerProductCategory CP,Customer C ,Beat_Salesman BT
		Where
			C.Active = 1
			And C.CustomerID = CP.CustomerID
			And BT.CustomerID = CP.CustomerID 
			And isNull(BT.SalesmanID,0) <> 0
			And isNull(BT.BeatID,0) <> 0
			And CP.CategoryID In (Select CatID From @tmpSubCat)
			And CP.Active = 1
			And C.CustomerCategory <> 5
	End

	Return @cnt
End
