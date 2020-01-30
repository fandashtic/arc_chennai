CREATE procedure sp_ser_checkCreditcardAccount(@bankID int)
as
Declare @GroupID int
Declare @GroupName varchar(255), @AccountGroupID int, @retval int set @retval = 0
select @AccountGroupID = GroupID from AccountsMaster
Inner Join Bank On Bank.AccountID = AccountsMaster.AccountID
Where BankID = @BankID
If isnull(@AccountGroupID, 0) > 0 
begin
	Create Table #tempgroup(GroupID int,GroupName varchar(255))
	Insert into #tempgroup select GroupID,GroupName From AccountGroup
	Where ParentGroup in(72)
	if exists(select * from #tempgroup where GroupID = @AccountGroupID) 
	begin 
		set @retVal = 1 
		goto overnout
	end		
	Declare Parent Cursor Dynamic For
	Select GroupID,GroupName From #tempgroup
	Open Parent
	         
	Fetch From Parent Into @GroupID,@GroupName        
	While @@Fetch_Status = 0        
	Begin        
		if exists(Select * From AccountGroup 
		Where ParentGroup = @GroupID and GroupID = @AccountGroupID) 
		begin 
			set @retval = 1 
			goto closenout
		end	
		Insert into #tempgroup
		Select GroupID,GroupName From AccountGroup
		Where ParentGroup = @GroupID
		Fetch Next From Parent Into @GroupID,@GroupName
	End
	if exists(select GroupID,GroupName From AccountGroup Where GroupID in(72) and GroupID = @AccountGroupID) 
	begin 
		set @retval = 1 
		goto closenout
	end	
closenout:
	Close Parent        
	DeAllocate Parent
overnout:
	Drop table #tempgroup 
end 
select @retval

