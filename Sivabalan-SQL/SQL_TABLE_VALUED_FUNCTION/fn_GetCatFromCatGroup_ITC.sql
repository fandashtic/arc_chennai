CREATE Function fn_GetCatFromCatGroup_ITC(@GroupNames nvarchar(4000),@Hierarchy NVARCHAR(50),@ParamDelimiter Char(1) = ',')    
Returns @CatID Table (CatID Int)    
As    
Begin    
  
Declare @CategoryID int      
Declare @Delimiter as Char(1)        
--Set @Delimiter = Char(15)    
Set @Delimiter = @ParamDelimiter  
  
declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)  
declare @tmpProductCategorygroupDetail Table(GroupID int, CategoryID Int)  
    
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

----------------  
Insert InTo @tmpProductCategorygroupDetail

Select "GroupID" = PCGA.GroupID, "CategoryID" = IC.CategoryID 
From ProductCategorygroupAbstract PCGA, tblCGDivMapping CGDM, ItemCategories IC
Where PCGA.GroupName = CGDM.CategoryGroup 
And CGDM.Division = IC.Category_Name

----------------

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
     @tmpProductCategorygroupAbstract as ProductCategorygroupAbstract,  
     @tmpProductCategorygroupDetail as ProductCategorygroupDetail 
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
  


