Create Function Fn_Get_ActiveStatus()
Returns @TempActive Table(ActiveID Int,Active nVarChar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
	Insert Into @TempActive Values (1,'Yes')
	Insert Into @TempActive Values (2,'No')
	Return
End
