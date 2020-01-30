
Create procedure [dbo].[sp_GetOutletCount_SManID_CatGrp]  
As
Begin
    --used in spr_SMan_Productivity_Measures report only
    --#tempCount must be created before calling the sp
	Declare @cnt as Int
	Declare @lvl as Int
	Declare @tmpSubCat Table(CatID  Int) 

    Declare @SmanID As Integer, @CatName As nVarchar(250), @Idnt As Integer

	Declare Cur_SMan Cursor Keyset For Select isnull(SmanID, 0), CatName, Idnt From #tempCount
    select @cnt = 0

	Open Cur_SMan    
	Fetch Next From Cur_SMan Into @SmanID, @CatName, @Idnt    
	    
	While @@Fetch_Status = 0    
	Begin 

        select @cnt = 0
        delete from @tmpSubCat
	    if @SmanID <> ''
	    Begin

			--Inserts All Subcategory under the category group.
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where ParentID In(Select CategoryID From ItemCategories Where 
			Category_Name In(Select Division From tblCGDivMapping 	Where CategoryGroup  = @CatName))
			And Active = 1

			--Inserts All Division
			Insert Into @tmpSubCat
			Select CategoryID From ItemCategories Where 
			Category_Name In(Select Division From tblCGDivMapping 	Where CategoryGroup  = @CatName)
			And Active = 1


			Select 
				@cnt = Count(Distinct CP.Customerid) 
			From 
				CustomerProductCategory CP,Customer C ,Beat_Salesman BT
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

        update #tempCount set outlet = @cnt where Idnt = @Idnt
        Fetch Next From Cur_SMan Into @SmanID, @CatName, @Idnt    
    end 
	Close Cur_SMan 
	Deallocate Cur_SMan 
End
