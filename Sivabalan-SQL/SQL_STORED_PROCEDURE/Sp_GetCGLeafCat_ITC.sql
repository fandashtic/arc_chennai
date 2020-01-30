Create Procedure Sp_GetCGLeafCat_ITC
					(@CategoryGroup nvarchar(2550),@ProductHierarchy nvarchar(255),                  
        		@Category nvarchar(2550))                  
As                  
Begin                  

Declare @Continue int                  
Declare @CategoryID int                
Declare @Company Nvarchar(50)
Declare @Division NVarchar(50)

Create table #tmpCat(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        

Set @Company = (select distinct HierarchyName from ItemHierarchy Where HierarchyID = 1)
Set @Division = (select distinct HierarchyName from ItemHierarchy Where HierarchyID = 2)

Set @Continue = 1                  
                
Declare @Delimeter as Char(1)                    
Set @Delimeter=Char(15)     

If @ProductHierarchy = @Company
	Begin
		if @Category=N'%%' or @Category = N'%' 
			Begin
				  Insert into #tmpCat 
					select Category_Name from ITemCategories
					where CategoryID in (Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@Division,@Delimeter))
					and ParentID in (Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,@Delimeter))
			End
		Else
			Begin
				 Insert into #tmpCat 
					select Category_Name from ITemCategories
					where CategoryID in (Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@Division,@Delimeter))
					and ParentID in (select CategoryID from ItemCategories  
		   										 where Category_Name in (select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)))
			End
	End
Else
	Begin	                   
		if @Category=N'%%' or @Category = N'%'                                   
		Begin
		  Insert into #tmpCat 
      select Category_Name from ItemCategories              
		  Where CategoryID in 
      (Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,@Delimeter)) 
		End
		Else    
		Begin               
			 Insert into #tmpCat 
       select Category_Name from ItemCategories  
		   where Category_Name in (select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))  
		   and CategoryID in (Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,@Delimeter))      
		End
  End
       
	Insert into #tempCategory select CategoryID, 0       
	From ItemCategories     
	Where ItemCategories.Category_Name In (Select Distinct Category from #tmpCat) 
	                    
	While @Continue > 0                  
	Begin                  
	 Declare Parent Cursor Keyset For                  
	 Select CategoryID From #tempCategory Where Status = 0                  
	 Open Parent                  
	 Fetch From Parent Into @CategoryID                  
	 While @@Fetch_Status = 0                  
	 Begin                  
	  Insert into #tempCategory                   
	  Select CategoryID, 0 From ItemCategories                   
	  Where ParentID = @CategoryID                  
	  If @@RowCount > 0                   
	   Update #tempCategory Set Status = 1 Where CategoryID = @CategoryID                  
	  Else                  
	   Update #tempCategory Set Status = 2 Where CategoryID = @CategoryID                  
	  Fetch Next From Parent Into @CategoryID                  
	 End                  
	 Close Parent                  
	 DeAllocate Parent                  
	 Select @Continue = Count(*) From #tempCategory Where Status = 0                  
	End                  
	Delete #tempCategory Where Status not in (0, 2)
  Drop Table #tmpCat                       
 End  

