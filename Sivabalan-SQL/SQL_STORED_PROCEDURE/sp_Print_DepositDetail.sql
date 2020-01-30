CREATE Procedure sp_Print_DepositDetail (@ParamInfo nvarchar(255))
As
Declare @BankID Int
Declare @DepositDate Datetime
Declare @Pos Int
Declare @Len Int

Set @Pos = CharIndex('|', @ParamInfo, 1)
Set @BankID = SubString(@ParamInfo, 1, @Pos - 1)
Set @Len = Len(@ParamInfo) - @Pos 
Set @DepositDate = Cast(SubString(@ParamInfo, @Pos + 1, @Len) as Datetime)
Select "CustomerID" = Collections.CustomerID, 
"Customer" = Customer.Company_Name, 
"Bank Name" = BankMaster.BankName,
"Bank Code" = Collections.BankCode, 
"Branch Code" = Collections.BranchCode, 
"Branch Name" = BranchMaster.BranchName,
"Cheque No" = Collections.ChequeNumber, 
"Cheque Date" = Collections.ChequeDate, 
"Amount" = Collections.Value
From Collections, BankMaster, BranchMaster, Customer
Where Collections.Deposit_To = @BankID And
dbo.StripDateFromTime(Collections.DepositDate) = dbo.StripDateFromTime(@DepositDate) And
Collections.CustomerID = Customer.CustomerID And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
