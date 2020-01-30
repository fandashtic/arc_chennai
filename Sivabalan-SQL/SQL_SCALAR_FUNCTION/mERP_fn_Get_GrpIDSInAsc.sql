Create Function mERP_fn_Get_GrpIDSInAsc(@SalesmanID Int)
Returns nVarchar(1000)
As
Begin

	Declare @GrpID as Int
	Declare @CGID as nVarchar(1000)
	Declare @tmpGrpID as Table(GroupID Int,GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


	
	Insert Into @tmpGrpID
	Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)	

	Declare Cur_CG Cursor For
	Select GroupID From @tmpGrpID Order By GroupID

	Open Cur_CG
	Fetch From Cur_CG Into @GrpID
	While @@Fetch_Status = 0
	Begin
		
		If isNull(@CGID,'') = ''
			Set @CGID = cast(@GrpID as nVarchar)
		Else
			Set @CGID = Cast(@CGID as nVarchar) + ',' + Cast(@GrpID as nVarchar)
			
		Fetch Next From Cur_CG Into @GrpID
	End	
	Close Cur_CG
	Deallocate Cur_CG


	If isNull(@CGID,'-1') = '-1'
		Set @CGID = '0'
	Else
		Set @CGID = ltrim(rtrim(@CGID))

	Return @CGID

End


