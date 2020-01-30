CREATE Procedure GetAllChildCategories_ITC
(
 @ParentCategoryID Int
)
As      
Declare @Continue int        
Declare @CategoryID int        
Set @Continue = 1        
      
Insert Into #TempCategory Select @ParentCategoryID,0             

While @Continue > 0        
Begin        
 Declare Parent Cursor Keyset For Select CategoryID From #TempCategory Where Status = 0        
 Open Parent        
 Fetch From Parent Into @CategoryID        
 While @@Fetch_Status = 0        
 Begin        
  Insert Into #TempCategory Select CategoryID, 0 From ItemCategories         
  Where ParentID = @CategoryID        
  If @@RowCount > 0         
   Update #TempCategory Set Status = 1 Where CategoryID = @CategoryID        
  Else        
   Update #TempCategory Set Status = 2 Where CategoryID = @CategoryID        
  Fetch Next From Parent Into @CategoryID        
 End        
 Close Parent        
 DeAllocate Parent        
 Select @Continue = Count(*) From #TempCategory Where Status = 0        
End

