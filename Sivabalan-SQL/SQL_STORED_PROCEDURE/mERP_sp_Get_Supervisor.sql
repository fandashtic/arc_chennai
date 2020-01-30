Create Procedure mERP_sp_Get_Supervisor(@SalesmanID As Int)
As
Begin
	

	--Insert All Mapped Supervisors for the salesman	
	Select 
		SuperVisor.SalesmanID,SuperVisor.SalesmanName 
	From 
		Salesman2 SuperVisor,tbl_mERP_SupervisorSalesman SS
	Where 
		SS.SalesmanID = @SalesmanID And
		SuperVisor.Active = 1 And
		SuperVisor.SalesmanID = SS.SupervisorId	
	
	Union

	--Insert All Unmapped Supervisors
	Select 
		SalesmanID ,SalesmanName 
	From 
		Salesman2 
	Where
		SalesmanID Not In(Select SupervisorID From tbl_mERP_SupervisorSalesman)
		And Active = 1
	

End 
