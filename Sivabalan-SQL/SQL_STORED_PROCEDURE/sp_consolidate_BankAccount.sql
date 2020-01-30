
CREATE procedure sp_consolidate_BankAccount (@Client_ID int,
					     @BankID int,
					     @Active int,
					     @Account_Name nvarchar(255),
					     @Account_Number nvarchar(50),
					     @BankCode nvarchar(20),
					     @BranchCode nvarchar(20))
as
If not Exists(Select BankID From Bank Where (Account_Number = @Account_Number 
Or Account_Name = @Account_Name) And BankCode = @BankCode)
Begin
	Insert into Bank (Client_ID, OriginalID, Active, Account_Name, Account_Number,
	BankCode, BranchCode) Values (@Client_ID, @BankID, @Active, @Account_Name,
	@Account_Number, @BankCode, @BranchCode)
End
Else
Begin
	Update Bank Set Active = @Active, Account_Name = @Account_Name,
	Account_Number = @Account_Number, BankCode = @BankCode, BranchCode = @BranchCode
	Where Account_Number = @Account_Number  And BankCode = @BankCode
End

