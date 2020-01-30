create Function fn_GetCGFrmCGtype_Itc(@GroupNames nvarchar(4000), @Hierarchy NVARCHAR(50), @CGtype nvarchar(100), @ParamDelimiter Char(1) = ',')    
Returns @CatID Table (CatID Int,GroupName nvarchar(255))    
As    
Begin

Declare @CategoryID int, @groupid int
Declare @Delimiter as Char(1)

IF CHARINDEX(@ParamDelimiter , @GroupNames,1) > 0 
Begin
    Set @Delimiter = @ParamDelimiter  
End
Else
Begin
    Set @Delimiter = Char(15) 
End
  
Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)  
    
if @GroupNames = N'%%'  or @GroupNames = N'%'  
Begin  
--    Insert into @tmpProductCategorygroupAbstract   
--    select GroupName,GroupID From ProductCategorygroupAbstract where OCGtype = ( Case when @CGtype = 'Operational' then 1 Else 0 End )
If @CGtype='Operational'  
 Insert into @tmpProductCategorygroupAbstract
 Select GroupName,GroupID From productcategorygroupabstract where OCGtype = 1  
Else  
 Insert Into @tmpProductCategorygroupAbstract   
 Select GroupName,GroupID From productcategorygroupabstract where GroupName in (Select distinct CategoryGroup from tblcgdivmapping)  

End    
Else    
Begin  
    Insert into @tmpProductCategorygroupAbstract   
    select GroupName,GroupID From ProductCategorygroupAbstract  
    Where ProductCategorygroupAbstract.GroupName in    
    (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))    
End    
If @CGtype = 'Regular' 
Begin
    Insert InTo @TempCGCatMapping  
    Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
    "CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
    From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
    Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

    declare @tempItemhierarchy Table(HierarchyID int)    

    If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = 'Division'  
        Insert Into @tempItemhierarchy Select HierarchyID From Itemhierarchy where hierarchyid = 2 --SecondLevel is the default  
    Else
        Insert Into @tempItemhierarchy   
        select HierarchyID From Itemhierarchy    
        where HierarchyName = @Hierarchy  
  
--Find all Category which are parent or Child or same for the Category group  
    Declare @RootToChild Table(CategoryId int,HierarchyID int,GroupName nvarchar(255))        
	
    DECLARE CRootToChild CURSOR KEYSET FOR                                
    SELECT CategoryID from  
    (  
    select distinct CategoryID
    from   
        @tmpProductCategorygroupAbstract as ProductCategorygroupAbstract, @TempCGCatMapping as ProductCategorygroupDetail  
    where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid  
    ) tmp  

    Open  CRootToChild                                
    Fetch From CRootToChild into @CategoryID                              
    WHILE @@FETCH_STATUS = 0                                
    BEGIN     
        insert into @RootToChild (CategoryId,HierarchyID) 
        select * from sp_get_Catergory_RootToChild(@CategoryID)  
		
        Fetch next From CRootToChild into @CategoryID
    END  
    Deallocate CRootToChild  
  
    Insert @CatID   
    select distinct CategoryID,'' from @RootToChild  
    where HierarchyID In (Select HierarchyID From @tempItemhierarchy)    
End  
Else    
Begin
    If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = ''  
        Select @Hierarchy  = 'Division'
	Declare @GroupName nvarchar(255)
    DECLARE GetGrpId CURSOR KEYSET FOR SELECT GroupId,GroupName from @tmpProductCategorygroupAbstract 
    Open GetGrpId
    Fetch From GetGrpId into @GroupId,@GroupName
    WHILE @@FETCH_STATUS = 0
    BEGIN
		If @Hierarchy ='Division'
			Insert @CatID
			select Distinct IC.CategoryID,@GroupName  From ItemCategories IC, OCGItemMaster FN Where isnull(Level,0)=2
			And FN.Division = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
		Else if @Hierarchy='Sub_Category'
			Insert @CatID 
			select Distinct IC.CategoryID,@GroupName From ItemCategories IC, OCGItemMaster FN Where isnull(Level,0)=3
			And FN.Subcategory = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
		Else if @Hierarchy='Market_SKU'
			Insert @CatID 
			select Distinct IC.CategoryID,@GroupName From ItemCategories IC, OCGItemMaster FN Where isnull(Level,0)=4
			And FN.MarketSKU = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
		Fetch next from GetGrpId into @GroupId,@GroupName
    END
    Close GetGrpId
    Deallocate GetGrpId
End  
Return
End    
