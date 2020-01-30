
Create procedure [dbo].[sp_GetOutletCount_SManID_CatGrp_OCG]  (@catType as nVarchar(100) = 'Regular')
As
Begin
--****************************************************************************************
	
	IF @catType = 'Regular'
	Begin
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
--*****************************************************************************************************************************************
	Else
	Begin
		Declare @CatGrp table (GroupName nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
		Insert into @CatGrp (GroupName) select distinct GroupName from productcategorygroupabstract where ocgtype=1

		Declare @Customer as Table (Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Salesmanid int,
		categoryid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Category_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		GroupName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		ParentID Int,
		ParentName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

		Delete from @Customer
		Insert Into @Customer(Customerid,Salesmanid,categoryid,category_name,GroupName)
		select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
		from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,
		(select Distinct IC3.Category_Name Sub_Category,IC2.Category_Name Division,G.GroupName CategoryGroup
		from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
		where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		And G.GroupID = F.GroupID) T2
		where BS.Customerid = CPC.Customerid
		And C.Active = 1 and C.CustomerCategory <> 5 
		and IC.categoryid = CPC.categoryid
		And CPC.Customerid= C.Customerid
		And IC.Category_Name = T2.Sub_Category

		Insert Into @Customer(Customerid,Salesmanid,categoryid,category_name,GroupName)
		select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
		from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,
		(select Distinct IC3.Category_Name Sub_Category,IC2.Category_Name Division,G.GroupName CategoryGroup
		from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
		where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		And G.GroupID = F.GroupID)  T2
		where BS.Customerid = CPC.Customerid
		And C.Active = 1 and C.CustomerCategory <> 5 
		and IC.categoryid = CPC.categoryid
		And CPC.Customerid= C.Customerid
		And IC.Category_Name = T2.Division

		Update T  Set T.Parentid = IC.Parentid from ItemCategories IC, @Customer T Where IC.CateGoryid = T.CateGoryid
		Update T  Set T.ParentName = IC.category_name from ItemCategories IC, @Customer T Where IC.CateGoryid = T.Parentid
		Update @Customer set ParentName = category_name Where ParentName = 'ITD'
		Delete from @Customer where GroupName is null 

		Delete from @Customer where SalesmanID Not In(Select Distinct SManID From #tempCount) And GroupName not in (select GroupName from @CatGrp)
		
		Declare @GrpName as nVarchar(20)
		Declare CurCatGroup Cursor For
		select GroupName from @CatGrp
		Open CurCatGroup
		Fetch From CurCatGroup Into @GrpName
		While @@Fetch_Status = 0
		Begin

		update T set T.outlet = T1.cnt From #tempCount T,
		(select SalesmanID,GroupName,Count(Distinct Customerid) cnt from @Customer Where GroupName = @GrpName Group By SalesmanID,GroupName) T1
		Where T.SManID = T1.SalesmanID
		And T.Catname = T1.GroupName

			Fetch Next From CurCatGroup Into @GrpName	
		End
		Close CurCatGroup
		Deallocate CurCatGroup



	Delete From @Customer
	Delete From @CatGrp
	End
--*****************************************************************************************************************************************
End
