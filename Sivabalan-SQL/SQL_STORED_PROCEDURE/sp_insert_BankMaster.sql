Create procedure sp_insert_BankMaster (@BankCode nvarchar(10), @BankName nvarchar(50))  
as  
Begin
	if Not Exists(select * from bankMaster where bankcode=@BankCode and bankname=@BankName)
	  Insert into BankMaster (BankCode, BankName, Active) Values (@BankCode, @BankName, 1)  
	else
	  update BankMaster set BankName=@BankName where BankCode=@BankCode and Active=1
End
