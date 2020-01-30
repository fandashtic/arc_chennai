CREATE Procedure sp_han_CheckBanknBranch(@BankCode nVarchar(50),@BranchCode nVarchar(50))
As
Declare @Status nVarchar(50)
Select @Status = Case  
		When Count(BankCode) = 0 then 'invalid bank code [' + (Case When @BankCode = '' then 'empty' else @BankCode end) + '].'
		else ''
		end
from BankMaster Where BankCode = @BankCode
if isNull(@Status,'') = ''
Select @Status = Case  
		When Count(BranchCode) = 0 then 'invalid branch code [' + (Case When @BranchCode = '' then 'empty' else @BranchCode end)   + '].'
		else ''
		end
from BranchMaster Where BranchCode = @BranchCode 
and BankCode = @BankCode
Select "ErrStatus" = IsNull(@Status,'')
