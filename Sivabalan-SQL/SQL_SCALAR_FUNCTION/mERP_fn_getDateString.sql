Create Function mERP_fn_getDateString(@Date Datetime)
Returns nVarchar(25)
As
Begin
	Declare @TmpDate nVarchar(25)
	Set @TmpDate = convert(varchar(10), @date, 103)
        Set @TmpDate = substring(@TmpDate, 1, 2) + '/' + substring(@TmpDate, 4, 2) + '/' + substring(@TmpDate, 7, 4)
	Return @TmpDate
End
