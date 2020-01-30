create procedure sp_acc_listbranches(@BankCode nvarchar(20),@KeyField nvarchar(30)=N'%',
@Direction int = 0, @BookMark nvarchar(128) = N'')
as
IF @Direction = 1
Begin
	Select BranchCode,BranchName 
	from BranchMaster Where BankCode = @BankCode and IsNull(Active,0)= 1
	and BranchName like @KeyField and BranchName > @BookMark
	Order By BranchName,BranchCode
End
Else
Begin
	Select BranchCode,BranchName 
	from BranchMaster Where BankCode = @BankCode
	and IsNull(Active,0)= 1
	and BranchName like @KeyField 
	Order By BranchName,BranchCode
End



