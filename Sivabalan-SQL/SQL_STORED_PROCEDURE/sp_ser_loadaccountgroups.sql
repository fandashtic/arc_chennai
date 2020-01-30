CREATE procedure sp_ser_loadaccountgroups(@Mode Int = 0,@ParentID Int = 0)        
as        
Declare @GroupID int        
Declare @GroupName varchar(255)        
Create Table #tempgroup(GroupID int,GroupName varchar(255))        
        
If @Mode = 1        
Begin        
	Insert into #tempgroup select GroupID,GroupName From AccountGroup        
	Where ParentGroup in(7,18,72)        
	         
	Declare Parent Cursor Dynamic For        
	Select GroupID,GroupName From #tempgroup         
	Open Parent        
	         
	Fetch From Parent Into @GroupID,@GroupName        
	While @@Fetch_Status = 0        
	Begin        
		Insert into #tempgroup         
		Select GroupID,GroupName From AccountGroup        
		Where ParentGroup = @GroupID        
		Fetch Next From Parent Into @GroupID,@GroupName         
	End        
	Close Parent        
	DeAllocate Parent        
	Insert into #tempgroup        
	select GroupID,GroupName From AccountGroup        
	Where GroupID in(7,18,72)        
	select * from #tempgroup order by groupname       
End        
Else        
Begin        
	Insert into #tempgroup select GroupID,GroupName From AccountGroup        
	Where ParentGroup = @parentid        
	 
	Declare Parent Cursor Dynamic For        
	Select GroupID,GroupName From #tempgroup         
	Open Parent        
	 
	Fetch From Parent Into @GroupID,@GroupName        
	While @@Fetch_Status = 0        
	Begin        
		Insert into #tempgroup         
		Select GroupID,GroupName From AccountGroup        
		Where ParentGroup = @GroupID        
		Fetch Next From Parent Into @GroupID,@GroupName         
	End        
	Close Parent        
	DeAllocate Parent        
	Insert into #tempgroup        
	select GroupID,GroupName From AccountGroup        
	Where GroupID = @parentid        
	select * from #tempgroup order by groupname        
End        
drop table #tempgroup       

