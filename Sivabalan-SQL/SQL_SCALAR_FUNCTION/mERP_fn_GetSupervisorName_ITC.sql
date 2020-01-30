CREATE Function mERP_fn_GetSupervisorName_ITC(@SalesmanID Int)    
Returns nVarchar(2000)
As    
Begin    
Declare @SupervisorName nVarchar(256)
Declare @MultiSupervisorName nVarchar(2000)
Declare @Increment Int

Set @SupervisorName = ''
Set @MultiSupervisorName = ''
Set @Increment = 0

If exists (select * from dbo.sysobjects 
where name Like 'tbl_mERP_SupervisorSalesman' and xtype in (N'U'))
Begin
	Declare  Cur_SupervisorName Cursor For 
		Select SalesmanName From Salesman2
		Where SalesmanID In (Select SupervisorID From tbl_mERP_SupervisorSalesman 
								Where SalesmanID = @SalesmanID)

		Open Cur_SupervisorName
		Fetch Next From Cur_SupervisorName Into @SupervisorName    
		While @@Fetch_Status = 0    
		Begin    
			If @Increment = 1
			Begin
				Set @MultiSupervisorName = @MultiSupervisorName + ' | '
			End

			Set @MultiSupervisorName = @MultiSupervisorName + @SupervisorName
			Set @Increment = 1

			Fetch Next From Cur_SupervisorName Into @SupervisorName
		End
		Close Cur_SupervisorName
		Deallocate Cur_SupervisorName

		If @Increment = 0
		Begin
			If @SalesmanID = 0
				Set @MultiSupervisorName = ''
			Else 
				Set @MultiSupervisorName = 'No Supervisor'
		End 

End
Else
Begin
	If @SalesmanID = 0
		Set @MultiSupervisorName = ''
	Else
		Set @MultiSupervisorName = 'N/A'
	
End

Return @MultiSupervisorName

End
