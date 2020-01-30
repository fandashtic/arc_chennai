CREATE Procedure sp_Print_DepositAbstract(@ParamInfo nvarchar(255))
As
Declare @BankID Int
Declare @DepositDate Datetime
Declare @Pos Int
Declare @Len Int

Set @Pos = CharIndex('|', @ParamInfo, 1)
Set @BankID = SubString(@ParamInfo, 1, @Pos - 1)
Set @Len = Len(@ParamInfo) - @Pos 
Set @DepositDate = Cast(SubString(@ParamInfo, @Pos + 1, @Len) as Datetime)
Select "Deposit Date" = dbo.StripDateFromTime(Collections.DepositDate), 
"Account Name" = Bank.Account_Name, 
"Account No" = Bank.Account_Number, 
"Bank Name" = BankMaster.BankName, 
"Branch Name" = BranchMaster.BranchName,
"Bank Code" = Bank.BankCode,
"Branch Code" = Bank.BranchCode,
"Total Amount" = Sum(Collections.Value)
From Collections, Bank, BranchMaster, BankMaster
Where Collections.Deposit_To = @BankID And
dbo.StripDateFromTime(Collections.DepositDate) = dbo.StripDateFromTime(@DepositDate) And
Collections.Deposit_To = Bank.BankID And
Bank.BranchCode = BranchMaster.BranchCode And
Bank.BankCode = BankMaster.BankCode And
Bank.BankCode = BranchMaster.BankCode
Group By dbo.StripDateFromTime(Collections.DepositDate), Bank.Account_Name, Bank.Account_Number,
BankMaster.BankName, Bank.BankCode, BranchMaster.BranchName, Bank.BranchCode
