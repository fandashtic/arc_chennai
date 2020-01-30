CREATE Function fn_GetCatFrmCG_ITC_OCG(@GroupNames nvarchar(4000),@Hierarchy NVARCHAR(50),@ParamDelimiter Char(1) = ',',@CatType nvarchar(4000) = '%')      
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
  
If @CatType = 'Regular'  
Begin  
 Insert InTo @TempCGCatMapping    
 Select Distinct "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup,   
 "CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division  
 From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat  
 Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name  
End  
Else If @CatType = 'Operational'  
Begin  
 Insert InTo @TempCGCatMapping    
 select Distinct "GroupID"  = PCG.GroupID, "GroupName" = PCG.GroupName, "CategoryID" = IC2.CategoryID,"CategoryName" =  IC2.Category_Name   
 from Fn_GetOCGSKU('%') F,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract PCG  
 Where F.GroupID = PCG.GroupId  
 And IC4.categoryId = F.categoryId  
 And IC4.ParentId = IC3.categoryid   
 And IC3.ParentId = IC2.categoryid   
End  
Else IF @CatType = '' or @CatType = '%' or @CatType = 'All'  
Begin  
 Insert InTo @TempCGCatMapping    
 Select Distinct "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup,   
 "CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division  
 From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat  
 Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name  
  
 Insert InTo @TempCGCatMapping    
 select Distinct "GroupID"  = PCG.GroupID, "GroupName" = PCG.GroupName, "CategoryID" = IC2.CategoryID,"CategoryName" =  IC2.Category_Name   
 from Fn_GetOCGSKU('%') F,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract PCG  
 Where F.GroupID = PCG.GroupId  
 And IC4.categoryId = F.categoryId  
 And IC4.ParentId = IC3.categoryid   
 And IC3.ParentId = IC2.categoryid   
End  
  
declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)    
      
if @GroupNames = N'%%'  or @GroupNames = N'%'    
Begin    
 If @CatType = 'Operational'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract Where isnull(OCGtype ,0) = 1  
 End  
 Else If @CatType = 'Regular'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract Where GroupName in (Select distinct CategoryGroup from tblcgdivmapping)  
 End  
 Else IF @CatType = '' or @CatType = '%' or @CatType = 'All'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract  
 End  
End      
Else      
Begin    
 If @CatType = 'Operational'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract    
  Where ProductCategorygroupAbstract.GroupName in      
  (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter)) And isnull(ProductCategorygroupAbstract.OCGtype ,0) = 1  
 End  
 Else If @CatType = 'Regular'  
 Begin   
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract    
  Where ProductCategorygroupAbstract.GroupName in      
  (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))  
 End    
 Else IF @CatType = '' or @CatType = '%' or @CatType = 'All'  
   Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract    
  Where ProductCategorygroupAbstract.GroupName in      
  (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))  
 End  
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
  
If @CatType = 'Operational'      
--If Exists(select * from @tmpProductCategorygroupAbstract Where GroupID in (select Distinct GroupID from ProductCategoryGroupAbstract where isnull(ocgtype,0) = 1 and active = 1))  
Begin  
 Declare @Level as Int  
 Select Top 1 @Level = HierarchyID From @tempItemhierarchy  
  
 If @Level = 2  
 Begin  
  Delete From  @CatID Where CatID NOt in (select Distinct IC2.Categoryid from Fn_GetOCGSKU('%') F,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2  
  Where Groupid in (select Distinct GroupId from @tmpProductCategorygroupAbstract)  
  And IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid)  
 End  
 Else If @Level = 3  
 Begin  
  Delete From  @CatID Where CatID NOt in (select Distinct IC3.Categoryid from Fn_GetOCGSKU('%') F,ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2  
  Where Groupid in (select Distinct GroupId from @tmpProductCategorygroupAbstract)  
  And IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid)  
 End  
End  
Return      
 End      

