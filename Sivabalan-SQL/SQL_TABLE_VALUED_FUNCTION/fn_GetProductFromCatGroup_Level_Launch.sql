Create Function fn_GetProductFromCatGroup_Level_Launch(@GroupNames nvarchar(4000),@Hierarchy nvarchar(2),@ParamDelimiter Char(1) = ',')    
Returns @Product Table (Product_Code nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
  
	Declare @CategoryID int      
	Declare @Delimiter as Char(1)        
	Set @Delimiter = @ParamDelimiter  
  
	declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  

	Declare @tmpProduct Table(Product_Code NVarChar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)
    
	if @GroupNames = N'%%'  or @GroupNames = N'%'  
	Begin  
		 Insert into @tmpProductCategorygroupAbstract   
		 Select Distinct CategoryGroup From tblCGDivMapping		
	End    
	Else    
	Begin  
		 Insert into @tmpProductCategorygroupAbstract   
		 Select Distinct CategoryGroup From tblCGDivMapping	 Where CategoryGroup In	
		 (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))    
	End    
  
	declare @tempItemhierarchy Table(HierarchyID int)    
  
	If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = '2'
		Insert Into @tempItemhierarchy Select HierarchyID From Itemhierarchy   where hierarchyid = 2 --SecondLevel is the default  
	Else    
		Insert Into @tempItemhierarchy   
		select HierarchyID From Itemhierarchy    
		where HierarchyId = cast(@Hierarchy  as int)
  
	--Find all Category which are parent or Child or same for the Category group  
	Declare  @RootToChild Table(CategoryId int,HierarchyID int)        
  
	DECLARE CRootToChild CURSOR KEYSET FOR                                
	SELECT CategoryID from  ItemCategories Where Category_Name In
	(Select Division From tblCGDivMapping Where CategoryGroup 
		In(Select GroupName From @tmpProductCategorygroupAbstract)
	)
  
	Open  CRootToChild                                
	Fetch From CRootToChild into @CategoryID                                
	WHILE @@FETCH_STATUS = 0                                
	BEGIN     
		 insert into @RootToChild  
		 select * from sp_get_Category_RootToChild_TMD(@CategoryID)  
		 Fetch next From CRootToChild into @CategoryID   
	END  
	Deallocate CRootToChild  
  
	Insert Into @tmpProduct
	Select Product_code From Items where categoryid in (
	select distinct CategoryID from  @RootToChild  
	where HierarchyID In (Select HierarchyID From @tempItemhierarchy))    

	Delete From @tmpProduct Where Product_Code in(Select Distinct ItemCode From LaunchItems LI, Items Where dbo.StripTimeFromDate(GetDate()) Between dbo.StripTimeFromDate(LaunchStartDate) 
		and dbo.StripTimeFromDate(LaunchEndDate) and LI.ItemCode = Items.Product_Code and isnull(LI.Active,0) = 1 and isnull(Items.Active,0) = 1) 

	Insert @Product
	Select Product_code From @tmpProduct
	  
	Return    
End    
  
