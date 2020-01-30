
Create procedure [dbo].[sp_GetOutletCount_SManID_CatName]  
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
--			    Insert Into @tmpSubCat
--			    Select ParentID from ItemCategories where category_name = @CatName 
--			    And Active = 1
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
        update #tempCount set outlet = @cnt where Idnt = @Idnt
        Fetch Next From Cur_SMan Into @SmanID, @CatName, @Idnt    
    end 
	Close Cur_SMan 
	Deallocate Cur_SMan 
End
