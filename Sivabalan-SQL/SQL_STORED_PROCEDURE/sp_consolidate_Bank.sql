
CREATE procedure sp_consolidate_Bank(@BankCode nvarchar(10),
				     @BankName nvarchar(50),
				     @Active int)
as
If not Exists(Select BankCode From BankMaster Where BankName = @BankName) 
Begin
	Insert into BankMaster Values(@BankCode, @BankName, @Active)
End
Else
Begin
	Update BankMaster Set Active = @Active Where BankCode = @BankCode
End

