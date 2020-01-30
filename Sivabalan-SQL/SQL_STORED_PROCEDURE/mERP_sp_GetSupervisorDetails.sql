Create Procedure mERP_sp_GetSupervisorDetails
(
@Supervisornames nVarchar(4000),
@Salesmannames nVarchar(4000)
)
As
Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)

Create Table #tmpSupervisor(SupervisorName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpSalesmanID(SalesmanID int)

If (@Supervisornames = N'%') OR  (@Supervisornames = N'All Supervisor')
Insert Into #tmpSupervisor Select Salesmanname From Salesman2
Else
Insert Into #tmpSupervisor Select Salesmanname
From Salesman2 Where Salesmanname In (Select * From dbo.sp_SplitIn2Rows(@Supervisornames, @Delimeter))


If ((@Supervisornames = N'%') OR  (@Supervisornames = N'All Supervisor')) and ((@Salesmannames <>  N'%') and (@Salesmannames <> 'All Salesman'))
Begin
	Insert Into #tmpSalesmanID
	Select Salesman.SalesmanID from Salesman where Salesman_name In( 
    (Select * From dbo.sp_SplitIn2Rows(@Salesmannames, @Delimeter)))


	Truncate table #tmpSupervisor
	Insert Into #tmpSupervisor
	Select 
		SuperVisor.SalesmanName 
	From 
		Salesman2 SuperVisor, tbl_mERP_SupervisorSalesman  SS
	Where 
		SuperVisor.SalesmanID = SS.SupervisorId	
		And SS.SalesmanID in (Select * from #tmpSalesmanID)

	Union

	--Insert All Unmapped Supervisors
	Select 
		SuperVisor.SalesmanName 
	From 
		Salesman2 SuperVisor
	Where
		SuperVisor.SalesmanID Not In(Select SupervisorID From tbl_mERP_SupervisorSalesman)
		And Active = 1


--	If (Select Count(*) From #tmpSupervisor) > 0 
--	Begin
		Select  Isnull(Salesmanname,'') as 'Supervisor Name',  Isnull(Salesmanname,'') as 'Supervisor Name',
				Replace(Isnull(Address,''), ',' ,' | ') as 'Address', 
				IsNull(ResidenceNo,'') as 'Residence Number',
				IsNull(MobileNo,'') as 'Mobile Number',
				( Select isnull(TypeDesc,'') from tbl_mERP_SupervisorType  where Salesman2.typeID = tbl_mERP_SupervisorType.TypeID) as 'Type',
				(case IsNull(Salesman2.Active,0) When 1 then 'Yes' else 'No' end) as 'Active'
		From Salesman2
		Where Salesman2.SalesmanName in (Select * from #tmpSupervisor)
--	End
End
Else
Begin
	Select "Supervisor Name" = Isnull(Salesmanname,''),  "Supervisor Name" = Isnull(Salesmanname,''),
			"Address" = Replace(Isnull(Address,''), ',' ,' | '), 
			"Residence Number" = IsNull(ResidenceNo,''),
			"Mobile Number" = IsNull(MobileNo,''),
			"Type" = ( Select isnull(TypeDesc,'') from tbl_mERP_SupervisorType  where Salesman2.typeID = tbl_mERP_SupervisorType.TypeID),
			"Active" = (case IsNull(Salesman2.Active,0) When 1 then 'Yes' else 'No' end) 
	From Salesman2
	Where Salesman2.SalesmanName in (Select * from #tmpSupervisor)
End

Drop table #tmpSupervisor
Drop table #tmpSalesmanID
