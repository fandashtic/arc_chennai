
create procedure sp_consolidate_Branch(@BranchCode nvarchar(20),
				       @BranchName nvarchar(50),
				       @Active int,
				       @BankName nvarchar(50))
as
Declare @BankCode nvarchar(50)

Select @BankCode = BankCode From BankMaster Where BankName = @BankName
If not Exists(Select BranchCode From BranchMaster Where BranchName = @BranchName)
Begin
	Insert into BranchMaster Values (@BranchCode, @BranchName, @Active, @BankCode)
End
Else
Begin
	Update BranchMaster Set Active = @Active,
	BankCode = @BankCode Where BranchCode = @BranchCode
End

