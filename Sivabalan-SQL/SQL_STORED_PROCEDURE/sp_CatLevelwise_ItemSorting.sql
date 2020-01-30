Create Procedure sp_CatLevelwise_ItemSorting
As
Declare @CategoryID int    

Declare @Continue int    
Set @Continue = 1    

Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      

Insert into #tmpCat1 select Category_Name from ItemCategories 
Where [Level] = 1 Order By Category_Name

Insert into #tempCategory1 select CategoryID, Category_Name, 0     
From ItemCategories  
Where ItemCategories.Category_Name In (Select Category from #tmpCat1)  
Order By Category_Name

While @Continue > 0    
Begin    
 Declare Parent Cursor Keyset For    
 Select CategoryID From #tempCategory1 Where Status = 0    
 Open Parent    
 Fetch From Parent Into @CategoryID    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempCategory1
  Select CategoryID, Category_Name, 0 From ItemCategories     
  Where ParentID = @CategoryID Order By Category_Name
  If @@RowCount > 0     
   Update #tempCategory1 Set Status = 1 Where CategoryID = @CategoryID    
  Else    
   Update #tempCategory1 Set Status = 2 Where CategoryID = @CategoryID    
  Fetch Next From Parent Into @CategoryID    
 End    
 Close Parent    
 DeAllocate Parent    
 Select @Continue = Count(*) From #tempCategory1 Where Status = 0    
End    

Drop Table #tmpCat1

