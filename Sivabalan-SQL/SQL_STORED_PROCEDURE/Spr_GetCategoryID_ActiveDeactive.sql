CREATE PROCEDURE Spr_GetCategoryID_ActiveDeactive (@CategoryID int, @STATUS int output)    
  
as      
Declare @ID int    
set @ID = @CategoryID    
Begin      
 create table #temp(categoryid int ,level int)    
 insert into #temp (CategoryID) Select CategoryID From ItemCategories Where ParentID = @CategoryID      
 DECLARE GetCategories CURSOR  FOR      
 Select CategoryID From #temp      
 Open GetCategories      
IF @@Fetch_Status = 0    
 insert into #temp (CategoryID) values (@CategoryID)    
Else    
  Fetch From GetCategories Into @CategoryID      
  While @@Fetch_Status = 0      
  Begin      
   insert into #temp (CategoryID) Select CategoryID From ItemCategories Where ParentID = @CategoryID      
   Fetch Next From GetCategories Into @CategoryID      
  End     
     
 Close GetCategories      
 Deallocate GetCategories      
    
update #temp set level = @ID     
IF (select count(*) from Items where categoryid in (select CategoryID From #temp)) = 0
BEGIN
	Update ItemCategories Set Active = 0 Where CategoryID in (select CategoryID From #temp)
	Select @STATUS = 1
END
ELSE
BEGIN
	Select @STATUS = 0
END
drop table #temp     
End
