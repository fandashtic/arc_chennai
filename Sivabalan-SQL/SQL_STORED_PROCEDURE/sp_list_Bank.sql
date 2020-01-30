CREATE procedure sp_list_Bank(@BANKCODE nvarchar(50),  @ACCOUNTNUMBER nvarchar(50),
@BankID int)
as
select ISNULL(BranchCode, N''), ISNULL(Account_Name, N''), Active 
from Bank where BankCode = @BANKCODE AND Account_Number = @ACCOUNTNUMBER And
BankID = @BankID
