Create Procedure mERP_sp_Get_ZoneCustomers(@Zone as nVarchar(2000))
As
Begin

	Declare @Delimeter as Char(1)
	Create Table #tmpZone(ZoneID Int)
	Declare @CustomerID As nVarchar(2000)

	Set @Delimeter= ','

	If @Zone = N'%' Or @Zone = N'' 
	Begin
		Insert Into #tmpZone Select ZoneID From tbl_mERP_Zone Where Active = 1
		Insert Into #tmpZone Select 0
	End
	Else
		Insert Into #tmpZone Select ZoneID From tbl_mERP_Zone Where ZoneID In(select * from dbo.sp_SplitIn2Rows(@Zone, @Delimeter))


	Set @CustomerID = ''
	Select @CustomerID =  @CustomerID + '''' + Cast(CustomerID as nVarchar(255)) + ''','   From Customer Where Active = 1 
	And ZoneID In(Select ZoneID From #tmpZone)

	If @CustomerID <> ''
	Set @CustomerID = Substring(@CustomerID,1,Len(@CustomerID)-1)

	Select @CustomerID


End
