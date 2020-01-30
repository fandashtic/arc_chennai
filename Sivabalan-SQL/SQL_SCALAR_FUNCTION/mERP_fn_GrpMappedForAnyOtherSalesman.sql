Create Function mERP_fn_GrpMappedForAnyOtherSalesman(@CustomerID nVarchar(500),@GrpID nVarchar(500))
Returns Int
As
Begin

	Declare @Exists Int
	Declare @SalesmanID Int
	Declare @tmpChkGrpID Table(GroupID Int)
	Declare @tmpGrpID Table(GroupID Int,GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

	
	
	Insert Into @tmpChkGrpID
	Select * From dbo.sp_splitIn2Rows(@GrpID,',')

	Declare Cur_Salesman CurSor  For
	Select  SalesmanID From Beat_Salesman Where isNull(CustomerID,'') = @CustomerID And isNull(BeatID,0) <> 0
	Open Cur_Salesman
	Fetch From Cur_Salesman Into @SalesmanID
	While @@Fetch_Status = 0
	Begin


		Delete From  @tmpGrpID
	
		/*Inserts All Category Group Mapped for the salesman */
		Insert Into @tmpGrpID
		Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)

		
		/* No category Group Mapped for the salesman */
		If (Select Count(*) From @tmpGrpID) = 0 
			Set @Exists = 1
		Else
		Begin
			If Exists(Select * from @tmpChkGrpID Where GroupID Not In(Select GroupID From @tmpGrpID))
				Set @Exists = 0
			Else
				Set @Exists = 1
		End
			
		If @Exists = 1 
		GoTo OverAndReturn		
		 
		Fetch Next From Cur_Salesman Into @SalesmanID
	
	End
OverAndReturn:		
	Close Cur_Salesman
	Deallocate Cur_Salesman

	Return @Exists
	
End

