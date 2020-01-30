CREATE procedure sp_acc_loadaccountgroups(@parentid integer,@Mode Int = 0)  
as  
Declare @GroupID int  
Declare @GroupName nvarchar(50)  
Create Table #tempgroup(GroupID int,GroupName nvarchar(50))  
  
If (isnull(@Mode, 0) = 1)
Begin  
	Insert into #tempgroup select GroupID,GroupName From AccountGroup  
	Where ParentGroup in(7,18)  
	
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
	Where GroupID in(7,18)  
	select * from #tempgroup  
End  
Else If (isnull(@Mode, 0) = 2) 
Begin  
	/* Mode 2 has been included for TCNS -- 72 to add Group under Credit card Group  */
	Insert into #tempgroup select GroupID,GroupName From AccountGroup  
	Where ParentGroup in(7,18, 72)  
	
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
	select * from #tempgroup  order by 2
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
	select * from #tempgroup  
End  
drop table #tempgroup 


