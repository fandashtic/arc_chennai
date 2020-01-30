CREATE procedure sp_acc_checkaccountgrouptype(@AccountID Int)
as
Select 'AccountType' = IsNull(AccountType,0),GroupName
from AccountGroup,AccountsMaster
Where AccountsMaster.AccountID = @AccountID
and AccountsMaster.GroupID = AccountGroup.GroupID


