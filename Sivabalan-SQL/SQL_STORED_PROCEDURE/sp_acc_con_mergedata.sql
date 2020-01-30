
CREATE procedure sp_acc_con_mergedata(@CompanyID nVarchar(255),@FromDate DateTime,
@ToDate DateTime,@MergeLocalCompany Int)
as
Declare @DynamicSQL nVarchar(4000)
Declare @ParentID Int,@ActualParentID Int 
Declare @ActualCompanyID nVarchar(128)
Declare @LocalCompanyID nVarchar(128)
Create Table #TempComp (Company nvarchar(128) Null)
Insert #TempComp
exec sp_acc_SqlSplit @CompanyID,N','
Select @LocalCompanyID = RegisteredOwner
From SetUp
set dateformat dmy
If @MergeLocalCompany = 1 
Begin
	Insert ReceiveAccountGroup	
	Exec sp_acc_con_sendAccountGroupdata
	Insert ReceiveAccount
	Exec sp_acc_con_sendAccountdata @FromDate,@ToDate
End
Set Identity_insert ConsolidateAccountGroup on 
Insert ConsolidateAccountGroup(GroupID,GroupName,AccountType,ParentGroup,Fixed)
Select GroupID,GroupName,AccountType,ParentGroup,Fixed
from ReceiveAccountGroup Where IsNull(Fixed,0) = 1
Group By GroupID,GroupName,AccountType,ParentGroup,Fixed
Set Identity_insert ConsolidateAccountGroup off
Insert ConsolidateAccountGroup(CompanyID,ActualGroupID,GroupName,AccountType,ParentGroup,Fixed)
Select CompanyID,GroupID,GroupName,AccountType,ParentGroup,Fixed 
from ReceiveAccountGroup Where IsNull(Fixed,0) <> 1 and CompanyID in (Select Company from #TempComp)
Set Identity_insert ConsolidateAccount on 
Insert ConsolidateAccount(AccountID,AccountName,GroupID,Fixed,OpeningBalance,ClosingBalance,Depreciation,FromDateOpeningBalance)
Select Max(AccountID),Max(AccountName),Max(AccountGroupID),Max(Fixed),Sum(OpeningBalance),
Sum(ClosingBalance),Sum(Depreciation),dbo.sp_acc_con_getfromdateopeningbalance(@FromDate,@CompanyID,1,Max(AccountID))
From ReceiveAccount Where CompanyID in (Select Company from #TempComp)
and [Date] = @ToDate and Fixed = 1 Group By AccountID
Set Identity_insert ConsolidateAccount off
Insert ConsolidateAccount(CompanyID,AccountName,GroupID,OpeningBalance,ClosingBalance,
Depreciation,ActualAccountID,FromDateOpeningBalance)
Select CompanyID,AccountName,AccountGroupID,OpeningBalance,ClosingBalance,Depreciation,AccountID,
dbo.sp_acc_con_getfromdateopeningbalance(@FromDate,CompanyID,2,AccountID)
From ReceiveAccount Where CompanyID in (Select Company from #TempComp)
and [Date] = @ToDate And IsNull(Fixed,0) <> 1
Declare scanconsolidate cursor keyset for
Select GroupID,ActualGroupID,CompanyID from ConsolidateAccountGroup 
Open scanconsolidate
Fetch From scanconsolidate Into @ParentID,@ActualParentID,@ActualCompanyID
While @@Fetch_Status = 0  
Begin
	Update ConsolidateAccount
	Set GroupID = @ParentID 
	Where GroupID = @ActualParentID 
	and CompanyID = @ActualCompanyID
	and IsNull(Fixed,0) <> 1
	
	Update ConsolidateAccountGroup
	Set ParentGroup = GroupID
	Where ParentGroup = ActualGroupID
	and CompanyID = @ActualCompanyID
	and IsNull(Fixed,0) <> 1
		 
	Fetch Next From scanconsolidate Into @ParentID,@ActualParentID,@ActualCompanyID
End
Close scanconsolidate
Deallocate scanconsolidate
Drop Table #TempComp

