CREATE procedure sp_ser_receiptaccounts(@Mode integer,@KeyField varchar(30)='%',
@Direction int = 0, @BookMark varchar(128) = '')
as
Declare @GroupID int
Declare @GroupName varchar(50)

DECLARE @RECEIPTS_OTHERS INT

SET @RECEIPTS_OTHERS =1

Create Table #tempgroup(GroupID int,GroupName varchar(50),Status integer)

IF @Mode = @RECEIPTS_OTHERS 
begin
	/*
	Groups
	Profit & Loss = 12,Stock in Trade = 21,Sales=28,Purchase=27,
	Cash in Hand=19,Cheque in Hand=20,Fixed Asset =13,PostdatedCheque 33
	Bank Accounts = 18
	Opening Stock=54,CLosing Stock=55
	Expense Groups	24,25,29
	Income Groups 26,31
	Duties&taxes - 9
	provisions for expenses - 10
	CreditCard in Hand,Coupons in hand,Others in hand - 50,51,52

	Accounts
	Net Profit = 20,Net Loss = 21
	*/
	Insert into #tempgroup
	Select GroupID,GroupName,1 from AccountGroup
	where ParentGroup in (12,21,18,28,27,19,20,13,33,54,55,24,25,26,31,9,10,50,51,52) and isnull(Active,0)=1

	Declare Parent Cursor Static For
	Select GroupID,GroupName From #tempgroup where status=1
	Open Parent
	Fetch From Parent Into @GroupID,@GroupName
	While @@Fetch_Status = 0
	Begin
		Insert into #tempgroup 
		Select GroupID,GroupName,1 From AccountGroup
		Where ParentGroup = @GroupID and isnull(Active,0)=1
		
	Fetch Next From Parent Into @GroupID,@GroupName 
	End
	Close Parent
	DeAllocate Parent
	Insert into #tempgroup
	Select GroupID,GroupName,1 from AccountGroup
	where GroupID in (12,21,28,18,27,19,20,13,33,54,55,24,25,26,31,17,8,9,10,50,51,52) and isnull(Active,0)=1
	-- 17-Current Liability, 8-Current Asset (to avoid accounts like bills payable, recivable, claims Payable, recivable)

	Insert #TempGroup
	select AccountsMaster.AccountID,AccountName,2 from AccountsMaster where GroupID 
	not in (Select GroupID from #TempGroup where status=1) and isnull(Active,0)=1 and 
	AccountID not in (Select Bank.AccountID from Bank)
	
	IF @Direction = 1
	Begin
		select GroupID,GroupName from #tempgroup where Status=2 and GroupID not in (20,21)  
		and GroupName like @KeyField and GroupName > @BookMark
		order by GroupName,GroupID
	End
	Else
	Begin
		select GroupID,GroupName from #tempgroup where Status=2 and GroupID not in (20,21)  
		and GroupName like @KeyField
		order by GroupName,GroupID
	End
	drop table #tempgroup	
end



