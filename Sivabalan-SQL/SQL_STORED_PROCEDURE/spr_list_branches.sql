Create PROCEDURE spr_list_branches
AS

Declare @ACTIVE As NVarchar(50)
Declare @INACTIVE As NVarchar(50)

Set @ACTIVE = dbo.LookupDictionaryItem(N'Active', Default)
Set @INACTIVE = dbo.LookupDictionaryItem(N'Inactive', Default)

SELECT BranchCode, "Branch Code" = BranchCode, "Branch Name" = BranchName,
"Bank Code" = BranchMaster.BankCode, "Bank Name" = BankMaster.BankName,
	"Active" = case BranchMaster.Active
	WHEN 1 THEN @ACTIVE
	ELSE @INACTIVE
	END
FROM BranchMaster, BankMaster
WHERE BranchMaster.BankCode = BankMaster.BankCode

