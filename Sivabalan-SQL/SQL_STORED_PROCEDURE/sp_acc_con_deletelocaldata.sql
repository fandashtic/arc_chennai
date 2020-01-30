
Create Procedure sp_acc_con_deletelocaldata
As
Declare @LocalCompanyID nVarchar(128)
Select @LocalCompanyID = RegisteredOwner
From SetUp
Delete ReceiveAccountGroup
Where CompanyID = @LocalCompanyID
Delete ReceiveAccount
Where CompanyID = @LocalCompanyID


