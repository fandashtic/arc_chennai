Create Function fn_ListCategoryGroup(@SalesmanID AS nVarchar(50))    
Returns @ProdCatGrp Table (GroupID Integer,GroupName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
	Declare @cnt as int

	
	/*Inserts All Category Group Mapped for the salesman */
	Insert Into @ProdCatGrp
	Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)


	/* If Salesman is not mapped to any of the DSType  or the
	   DSTypeID mapped for the salesman do not any valid CG Mapping then 
	   insert all the CategoryGroup */
--	If ((Select Count(*) From  @ProdCatGrp) = 0 And @SalesmanID <> 0 )
--	Begin
--		Insert Into @ProdCatGrp    
--		Select
--			PCA.GroupID ,PCA.GroupName    
--		From
--			ProductCategoryGroupAbstract PCA     
--		Where
--			Active = 1   
--	End
		
	
	Return   
End  

