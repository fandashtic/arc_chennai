Create Function fn_GetCatFromCatGroup_TMD(@GroupNames nvarchar(4000),@Hierarchy NVARCHAR(50),@ParamDelimiter Char(1) = ',')    
Returns @CatID Table (CatID Int)    
As    
Begin    
  
	Declare @CategoryID int      
	Declare @Delimiter as Char(1)        
	Set @Delimiter = @ParamDelimiter  
  
	declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  
    
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
  
	If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = 'Division'  
		Insert Into @tempItemhierarchy Select HierarchyID From Itemhierarchy   where hierarchyid = 2 --SecondLevel is the default  
	Else    
		Insert Into @tempItemhierarchy   
		select HierarchyID From Itemhierarchy    
		where HierarchyName = @Hierarchy  
  
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
  
	Insert @CatID   
	select distinct CategoryID from  @RootToChild  
	where HierarchyID In (Select HierarchyID From @tempItemhierarchy)    
	  
	Return    
End    
  
