CREATE procedure sp_ser_loadbankaccount (@CreditCardID integer)
as
Select distinct Account_Number, Bank.BankID, BankMaster.BankName from Bank 
inner Join BankMaster On BankMaster.BankCode = Bank.BankCode 
inner Join BankAccount_PaymentModes on BankAccount_PaymentModes.BankID = Bank.BankID 
where CreditCardID = @CreditCardID and Bank.Active = 1 
order by Account_Number
/*
Declare @GroupID int
Declare @GroupName varchar(50)

Create Table #tempgroup(GroupID int,GroupName varchar(50))
Insert into #tempgroup select GroupID,GroupName From AccountGroup
Where ParentGroup = @ingroupid or GroupID = @ingroupid

Declare Parent Cursor Static For
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


Select Account_Number, BankID from bank b 
Where b.AccountID in (Select AccountID From AccountsMaster Where 
GroupID in (select GroupID from #tempgroup))

drop table #tempgroup
--- End of Procedure */
