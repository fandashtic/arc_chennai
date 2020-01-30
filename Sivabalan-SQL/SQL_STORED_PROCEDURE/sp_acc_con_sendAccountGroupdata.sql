

CREATE procedure sp_acc_con_sendAccountGroupdata
as
Declare @CompanyID nVarchar(128)

Select @CompanyID = RegisteredOwner From Setup
Select 'CompanyID' = @CompanyID,GroupID,GroupName,ParentGroup,
'AccountType' =IsNull(AccountType,0),'Fixed' = IsNull(Fixed,0)
From AccountGroup Where GroupID <> 500







