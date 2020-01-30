CREATE Procedure sp_acc_CheckParentGroup(@AccountID as Int)
As
Declare @GroupID int
Declare @MyParentGroup int
Declare @BANK_ACCOUNTS Int
Declare @BANK_OVERDRAFT_ACCOUNTS Int
Set @BANK_ACCOUNTS = 18
Set @BANK_OVERDRAFT_ACCOUNTS = 7
--Create Temporary tables to store groupids
Create Table #TempBankAccountGroup(GroupID int)
Create Table #TempBankOverDraftAccountGroup(GroupID int)
--Get The Parent Group from the Accounts Master
Select @MyParentGroup = GroupID from AccountsMaster Where AccountID = @AccountID
--Insert ChildGroups Of BankAccounts Group
Insert into #TempBankAccountGroup 
select GroupID From AccountGroup Where ParentGroup = @BANK_ACCOUNTS
--Insert All Leaf Level Child Groups
Declare BankAccountCur Cursor Dynamic For    
Select GroupID From #TempBankAccountGroup     
Open BankAccountCur    
Fetch From BankAccountCur Into @GroupID
While @@Fetch_Status = 0    
Begin    
	Insert into #TempBankAccountGroup     
	Select GroupID From AccountGroup Where ParentGroup = @GroupID    
	Fetch Next From BankAccountCur Into @GroupID
End    
Close BankAccountCur    
DeAllocate BankAccountCur    
--Insert BankAccounts Group
Insert into #TempBankAccountGroup    
select GroupID From AccountGroup Where GroupID = @BANK_ACCOUNTS

--Insert ChildGroups Of BankOD Group
Insert into #TempBankOverDraftAccountGroup 
select GroupID From AccountGroup Where ParentGroup = @BANK_OVERDRAFT_ACCOUNTS
--Insert All Leaf Level Child Groups
Declare BankODAccountCur Cursor Dynamic For    
Select GroupID From #TempBankOverDraftAccountGroup     
Open BankODAccountCur    
Fetch From BankODAccountCur Into @GroupID
While @@Fetch_Status = 0    
Begin    
	Insert into #TempBankOverDraftAccountGroup     
	Select GroupID From AccountGroup Where ParentGroup = @GroupID    
	Fetch Next From BankODAccountCur Into @GroupID
End    
Close BankODAccountCur    
DeAllocate BankODAccountCur    
--Insert BankOD Group
Insert into #TempBankOverDraftAccountGroup    
select GroupID From AccountGroup Where GroupID = @BANK_OVERDRAFT_ACCOUNTS
--Return ParentGroup of the Account Supplied
If Exists (Select GroupID from #TempBankAccountGroup Where GroupID = @MyParentGroup)
	Begin 
		Select @BANK_ACCOUNTS
	End
Else If Exists (Select GroupID from #TempBankOverDraftAccountGroup Where GroupID = @MyParentGroup)
	Begin 
		Select @BANK_OVERDRAFT_ACCOUNTS
	End
Else
	Begin
		Select @MyParentGroup
	End
--Drop the Temporary tables
Drop Table #TempBankAccountGroup
Drop Table #TempBankOverDraftAccountGroup
