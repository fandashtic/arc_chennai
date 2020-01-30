CREATE procedure sp_acc_autolistaccountswithoutactive(@parentid integer,@mode integer,    
@KeyField nvarchar(30)=N'%',@Direction int = 0, @BookMark nvarchar(128) = N'')    
as    
Declare @GroupID int    
Declare @GroupName nvarchar(255)    
    
if @mode =1     
begin    
 Create Table #tempgroup(AccountID int,AccountName nvarchar(255),[Account Group] nVarchar(100),Status integer)    
     
 Insert into #tempgroup select GroupID,GroupName,Null,1 From AccountGroup    
 Where ParentGroup = @parentid    
     
 Declare Parent Cursor Dynamic For    
 Select AccountID,AccountName From #tempgroup where status=1    
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup     
  Select GroupID,GroupName,Null,1 From AccountGroup    
  Where ParentGroup = @GroupID    
      
  Insert into #tempgroup     
  Select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG 
  Where AM.GroupID = @GroupID and AM.GroupID = AG.GroupID
     
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
 Insert into #tempgroup    
 select AM.AccountID,AM.AccountName,AG.GroupName,2 From AccountsMaster AM,AccountGroup AG 
 Where AM.GroupID = @parentid and AM.GroupID = AG.GroupID
     
 IF @Direction = 1    
 Begin     
  select AccountID,AccountName,[Account Group] from #tempgroup where Status=2    
  and AccountName like @KeyField and AccountName > @BookMark    
  order by AccountName    
 End    
 Else    
 Begin    
  select AccountID,AccountName,[Account Group] from #tempgroup where Status=2    
  and AccountName like @KeyField    
  order by AccountName    
 End    
    
 drop table #tempgroup    
end    
else if @mode =2     
begin    
 Create Table #tempgroup1(AccountID int,AccountName nvarchar(255),Status integer)    
     
 Insert into #tempgroup1 select GroupID,GroupName,1 From AccountGroup    
 Where ParentGroup = @parentid    
     
 Declare Parent Cursor Dynamic For    
 Select AccountID,AccountName From #tempgroup1 where status=1    
 Open Parent    
     
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroup1     
  Select GroupID,GroupName,1 From AccountGroup    
  Where ParentGroup = @GroupID    
      
  Insert into #tempgroup1     
  Select AccountID,AccountName,2 From AccountsMaster    
  Where GroupID = @GroupID    
     
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
      
 Insert into #tempgroup1    
 select AccountID,AccountName,2 From AccountsMaster     
 Where GroupID = @parentid     
     
 IF @Direction = 1    
 Begin     
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group] from AccountsMaster AM,AccountGroup AG 
  where AM.AccountID not in(select AccountID from #tempgroup1 where Status=2)    
  and AM.AccountID <> 500 and AM.AccountName like @keyfield and AM.AccountName > @BookMark    
  and AM.GroupID = AG.GroupID
  order by AccountName    
 End    
 Else    
 Begin    
  select Top 9 AM.AccountID,AM.AccountName,AG.GroupName as [Account Group]  from AccountsMaster AM,AccountGroup AG 
  where AM.AccountID not in(select AccountID from #tempgroup1 where Status=2)    
  and AM.AccountID <> 500 and AM.AccountName like @keyfield and AM.GroupID = AG.GroupID
  order by AccountName    
 End    
    
 drop table #tempgroup1    
end    
    
else if @mode =3     
begin    
 Create Table #tempgroupothers(AccountID int,AccountName nvarchar(255),
 [Account Group] nVarchar(100),Status integer)

 Insert into #tempgroupothers    
 Select GroupID,GroupName,Null,1 from AccountGroup    
 where ParentGroup in (19) and isnull(Active,0)=1    
    
 Declare Parent Cursor Dynamic For    
 Select AccountID,AccountName From #tempgroupothers where status=1 
 Open Parent    
 Fetch From Parent Into @GroupID,@GroupName    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempgroupothers    
  Select GroupID,GroupName,Null,1 From AccountGroup    
  Where ParentGroup = @GroupID and isnull(Active,0)=1    
      
 Fetch Next From Parent Into @GroupID,@GroupName     
 End    
 Close Parent    
 DeAllocate Parent    
 Insert into #tempgroupothers    
 Select GroupID,GroupName,Null,1 from AccountGroup    
 where GroupID in (19) and isnull(Active,0)=1    
    
 Insert #tempgroupothers    
 select AM.AccountID,AM.AccountName,AG.GroupName,2 from AccountsMaster AM,AccountGroup AG 
 where AM.GroupID in (Select AccountID from #tempgroupothers where status=1) 
 and isnull(AM.Active,0)=1 and AM.GroupID = AG.GroupID
     
 IF @Direction = 1    
 Begin    
  select AccountID,AccountName,[Account Group] from #tempgroupothers    
  where Status=2 and AccountName like @KeyField    
  and AccountName > @BookMark    
  order by AccountName    
 End    
 Else    
 Begin    
  select AccountID,AccountName,[Account Group] from #tempgroupothers 
  where Status=2 and AccountName like @KeyField    
  order by AccountName    
 End    
 drop table #tempgroupothers    
end   




