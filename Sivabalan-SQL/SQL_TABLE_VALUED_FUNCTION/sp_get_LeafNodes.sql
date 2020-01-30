CREATE Function sp_get_LeafNodes( @Node Int)     
Returns @LeafNodes Table(CategoryId int)    
As    
Begin    
    
 Declare @LOOP int     
 Declare @Temp_Tbl Table(CatId int)    
 Set @Loop = 1   
 Insert into @Temp_Tbl Values (@Node) 
 if Exists(Select CategoryId from ItemCategories Where ParentId= @Node)
 Begin
	 While (@Loop = 1)    
	 Begin     
	  Insert into @Temp_Tbl     
	  Select CategoryId From ItemCategories A     
	  Where ParentId in (Select CatId From @Temp_Tbl) and     
	    CategoryId not in (Select CatId From @Temp_Tbl)   
	    --and isnull((Select Count(*) From ItemCategories Where ParentId = A.CategoryId),0) > 0    
	      
	  if @@ROWCOUNT = 0 Set @Loop = 0    
	 End    
	 Insert into @LeafNodes    
	 Select CategoryID from ItemCategories A Where ParentID in (Select CatId From @Temp_Tbl) and     
	 isnull((Select Count(*) From ItemCategories Where ParentId = A.CategoryId),0) = 0    
	   
 End  
 Else
 	Insert into @LeafNodes Select CatId From @Temp_Tbl	
 Return
End    
  


