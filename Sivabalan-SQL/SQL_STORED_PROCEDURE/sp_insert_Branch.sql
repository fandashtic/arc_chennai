CREATE procedure sp_insert_Branch (@BranchCode nvarchar(10), @BranchName nvarchar(50), @BankCode nvarchar(10))  
as  
Begin
     if Not Exists (select * from BranchMaster where BranchCode=@BranchCode) 
	Insert into BranchMaster (BranchCode, BranchName, BankCode, Active) Values (@BranchCode, @BranchName, @BankCode, 1)  
     Else
	update BranchMaster set BranchName=@BranchName where BranchCode=@BranchCode and Active=1
End 
