CREATE procedure sp_ser_checkbankaccount(@AccountName as nvarchar(255))
as 
Select Bank.AccountId from AccountsMaster 
Inner Join Bank On Bank.AccountId = AccountsMaster.AccountID 
Where AccountName = @AccountName

