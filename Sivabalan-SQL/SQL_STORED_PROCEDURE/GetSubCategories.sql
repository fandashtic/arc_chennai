Create Procedure GetSubCategories (@Category nvarchar(2550))  
As  

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
create table #tmpCat(Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )
if @Category='%'
   insert into #tmpCat select Category_Name from ItemCategories
else
   insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category, @Delimeter)

Begin  
Declare @Continue int  
Declare @CategoryID int  
Set @Continue = 1  
Insert into #tempCategory select CategoryID, 0
From ItemCategories
Where ItemCategories.Category_Name In (select Category_Name from #tmpCat)
  
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
Delete #tempcategory Where Status not in  (0, 2)  
End 
drop table #tmpCat



