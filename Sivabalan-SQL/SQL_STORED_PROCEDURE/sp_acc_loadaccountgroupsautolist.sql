CREATE procedure sp_acc_loadaccountgroupsautolist(@parentid integer,@mode integer,    
@KeyField nvarchar(30)=N'%',@Direction int = 0, @BookMark nvarchar(128) = N'')    
as    
Declare @GroupID int    
Declare @GroupName nvarchar(100)    
    
if @mode =1    
begin    
 Create Table #tempgroup(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup select GroupID,GroupName From AccountGroup    
 Where ParentGroup = @parentid and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup     
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
 Insert into #tempgroup    
 select GroupID,GroupName From AccountGroup    
 Where GroupID = @parentid and isnull([Active],0)=1    
    
 IF @Direction = 1    
 Begin    
  select GroupID,GroupName from #tempgroup     
  where GroupName like @KeyField    
  and GroupName > @BookMark    
  order by GroupName       
 End    
 Else    
 Begin    
  select GroupID,GroupName from #tempgroup     
  where GroupName like @KeyField    
 End    
 drop table #tempgroup    
end    
else if @mode =2     
begin    
 Create Table #tempgroup1(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup1 select GroupID,GroupName From AccountGroup    
 Where ParentGroup = @parentid and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup1     
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup1     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
    
 Insert into #tempgroup1    
 select GroupID,GroupName From AccountGroup    
 Where GroupID = @parentid and isnull([Active],0)=1    
     
 IF @Direction = 1    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup1)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  and GroupName > @BookMark    
  Order by GroupName    
 End    
 Else    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup1)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  order by GroupName    
 End    
    
 drop table #tempgroup1    
end    
else if @mode = 3    
begin    
 Create Table #tempgroup2(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup2 select GroupID,GroupName From AccountGroup    
 Where ParentGroup in (1,7,11,12,13,18,21,22,35) and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup2     
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup2     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
    
 Insert into #tempgroup2    
 select GroupID,GroupName From AccountGroup    
 Where GroupID in (1,7,11,12,13,18,21,22,35) and isnull([Active],0)=1    
     
 IF @Direction = 1    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup2)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  and GroupName > @BookMark    
  Order by GroupName    
 End  
 Else    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup2)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  order by GroupName    
 End    
 drop table #tempgroup2    
end   
else if @mode = 4     
Begin    
 Create Table #tempgroup3(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup3 select GroupID,GroupName From AccountGroup    
 Where ParentGroup = 1 and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup3     
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup3     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
    
 Insert into #tempgroup3    
 select GroupID,GroupName From AccountGroup    
 Where GroupID = 1 and isnull([Active],0)=1    
      
 Select GroupID,GroupName from #tempgroup3    
 Where GroupID = @parentid    
End    
else if @mode = 5 -- Lists only Expense/Income Groups    
begin    
 Create Table #tempgroup4(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup4 select GroupID,GroupName From AccountGroup    
 Where ParentGroup in (24,25,26,31) and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup4    
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup4    
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
    
 Insert into #tempgroup4    
 select GroupID,GroupName From AccountGroup    
 Where GroupID in (24,25,26,31) and isnull([Active],0)=1    
     
 IF @Direction = 1    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID in (select GroupID from #tempgroup4)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  and GroupName > @BookMark    
  Order by GroupName    
 End    
 Else    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID in (select GroupID from #tempgroup4)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  order by GroupName    
 End    
 drop table #tempgroup4    
end    
else if @mode = 6 -- List all accounts under Capital Group in AccountsMaster module for pvt ltd company implementation    
begin    
 Create Table #tempgroup6(GroupID int,GroupName nvarchar(100))    
     
 Insert into #tempgroup6 select GroupID,GroupName From AccountGroup    
 Where ParentGroup in (7,11,12,13,18,21,22,35) and isnull([Active],0)=1    
     
 Declare Parent Cursor Dynamic For    
 Select GroupID,GroupName From #tempgroup6     
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup6     
  Select GroupID,GroupName From AccountGroup    
  Where ParentGroup = @GroupID and isnull([Active],0)=1    
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
    
 Insert into #tempgroup6    
 select GroupID,GroupName From AccountGroup    
 Where GroupID in (7,11,12,13,18,21,22,35) and isnull([Active],0)=1    
     
 IF @Direction = 1    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup6)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  and GroupName > @BookMark    
  Order by GroupName    
 End    
 Else    
 Begin    
  select GroupID,GroupName from AccountGroup    
  where GroupID not in(select GroupID from #tempgroup6)    
  and isnull(Active,0)=1 and GroupName like @keyfield    
  order by GroupName    
 End    
 drop table #tempgroup6    
end   



