Create Procedure Sp_CheckGroupExistsForSalesman(@SalesmanID Int,@GroupID nVarchar(1000))  
As
Begin

	Create Table #tmpCatGrp(GroupID Int,GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpGrpID(GroupID Int)



	/* This temporary table stores the GroupID so that we can check
	whether all the passed Catogory Group are mapped to the salesman */
	Insert Into #tmpGrpID
	Select * From dbo.sp_splitIn2Rows(@GroupID,',')
	
	
	/* Inserts All Category Mapped for the salesman */
	Insert Into #tmpCatGrp
	Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)



	/* All Categories mapped for the salesman */
	if @GroupID = '0' And  (Select Count(*) From  #tmpCatGrp) = 0
		Select 0
	Else
	Begin
		/* If Salesman is not mapped to any of the DSType  or the
		   DSType mapped for the salesman do not any valid CG Mapping then 
		   insert all the CategoryGroup */
--		If (Select Count(*) From  #tmpCatGrp) = 0 
--		Begin
--			Insert Into #tmpCatGrp    
--			Select
--				PCA.GroupID ,PCA.GroupName
--			From
--				ProductCategoryGroupAbstract PCA     
--			Where
--				Active = 1   
--		End



		If Exists(Select * from #tmpGrpID Where GroupID Not In(Select GroupID From #tmpCatGrp))
			Select 0
		Else
			Select 1
	End

End

