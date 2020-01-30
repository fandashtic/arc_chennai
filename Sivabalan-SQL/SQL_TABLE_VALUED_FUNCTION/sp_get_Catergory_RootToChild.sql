CREATE Function sp_get_Catergory_RootToChild(@NodeCategoryId Int)       
Returns @RootToChild Table(CategoryId int,HierarchyID int)      
As      
Begin      
      
 Declare @LOOP int       
 Declare @Temp_Tbl_Leaf Table(CatId int,HierarchyID int)      
 Declare @Temp_Tbl_Root Table(CatId int,HierarchyID int)      
 Set @Loop = 1     
--Insert Same Level
 Insert into @Temp_Tbl_Leaf 
 Select CategoryId,[Level] from ItemCategories Where CategoryId= @NodeCategoryId
--Find the Child
 if Exists(Select CategoryId from ItemCategories Where ParentId= @NodeCategoryId)  
 Begin  
  While (@Loop = 1)      
  Begin       
   Insert into @Temp_Tbl_Leaf       
   Select CategoryId,[Level] From ItemCategories A       
   Where ParentId in (Select CatId From @Temp_Tbl_Leaf) and       
     CategoryId not in (Select CatId From @Temp_Tbl_Leaf)     
         
   if @@ROWCOUNT = 0 Set @Loop = 0      
  End      
 End    
--Find the Parent
 Set @Loop = 1     
Insert into @Temp_Tbl_Root 
 Select CategoryId,[Level] from ItemCategories Where CategoryId= @NodeCategoryId
 if Exists(Select ParentId from ItemCategories Where CategoryId= @NodeCategoryId)  
 Begin  

  While (@Loop = 1)      
  Begin       
   Insert into @Temp_Tbl_Root       
   Select ParentId,[Level]-1 From ItemCategories A       
   Where CategoryId in (Select CatId From @Temp_Tbl_Root) and       
     ParentId not in (Select CatId From @Temp_Tbl_Root) and ParentId >0    

   if @@ROWCOUNT = 0 Set @Loop = 0      
  End      
 End    

  Insert into @RootToChild 
  Select CatId,HierarchyID From @Temp_Tbl_Leaf
  union --Union will give the distinct id's   
  Select CatId,HierarchyID From @Temp_Tbl_Root 

 Return  
End      
    
  
  


