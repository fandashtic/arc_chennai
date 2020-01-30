

CREATE procedure sp_acc_con_createrandomtable(@TableName nVarchar(255),@Mode Int)
as
Declare @DynamicTable nVarchar(4000)
	
If @Mode = 1 
Begin
	Set @DynamicTable = N'Create Table Tempdb..' + @TableName + N'(AccountID Int Identity(1,1),
	AccountName nVarchar(255),GroupID Int,Fixed Int Null,OpeningBalance Decimal(18,2),
	ClosingBalance Decimal(18,2),Depreciation Decimal(18,2),CompanyID nVarchar(128),FromDateOpeningBalance Decimal(18,2),ActualAccountID Int)'
End
Else if @Mode = 2
Begin
	Set @DynamicTable = N'Create Table Tempdb..' + @TableName + N'(CompanyID nVarchar(128) Null,
	GroupID Int Identity(1,1),GroupName nvarchar(255),AccountType Int Null,ParentGroup Int Null,
	Fixed Int Null,ActualGroupID Int)'
End
Else If @Mode = 3
Begin
	Set @DynamicTable = N'Create Table Tempdb..' + @TableName + N'(CompanyID nVarchar(128),AccountID Int,
	Balance Decimal(18,2),Fixed Int Null)'
End
exec sp_executesql @DynamicTable




