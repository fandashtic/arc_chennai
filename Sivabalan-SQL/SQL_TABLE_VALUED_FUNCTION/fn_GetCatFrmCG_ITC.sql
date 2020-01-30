CREATE Function fn_GetCatFrmCG_ITC(@GroupNames nvarchar(4000),@Hierarchy NVARCHAR(50),@ParamDelimiter Char(1) = ',')    
Returns @CatID Table (CatID Int)    
As    
Begin    
  
Declare @CategoryID int      
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

Insert InTo @TempCGCatMapping  
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)  
    
if @GroupNames = N'%%'  or @GroupNames = N'%'  
Begin  
     Insert into @tmpProductCategorygroupAbstract   
     select GroupName,GroupID From ProductCategorygroupAbstract  
End    
Else    
Begin  
     Insert into @tmpProductCategorygroupAbstract   
     select GroupName,GroupID From ProductCategorygroupAbstract  
     Where ProductCategorygroupAbstract.GroupName in    
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
SELECT CategoryID from  
(  
select distinct CategoryID   
from   
     @tmpProductCategorygroupAbstract as ProductCategorygroupAbstract,  @TempCGCatMapping as ProductCategorygroupDetail  
where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid  
) tmp  
  
Open  CRootToChild                                
Fetch From CRootToChild into @CategoryID                                
WHILE @@FETCH_STATUS = 0                                
BEGIN     
     insert into @RootToChild  
     select * from sp_get_Catergory_RootToChild(@CategoryID)  
     Fetch next From CRootToChild into @CategoryID   
END  
Deallocate CRootToChild  
  
Insert @CatID   
select distinct CategoryID from  @RootToChild  
where HierarchyID In (Select HierarchyID From @tempItemhierarchy)    
  
Return    
 End    
  


