Create Function mERP_fn_Get_DSTypeDS(@DSType nVarchar(4000))
Returns @Salesman Table(SalesmanID Int)
As
Begin
	Declare @Delimiter as nVarchar(1)
	Set @Delimiter = ','
	
	If @DSType = N'All' Or @DSType = '%%'
		Insert Into @Salesman 
		Select Distinct SalesmanID From DSType_Master Mast, DSType_Details Det 
		Where Mast.DSTypeID = Det.DSTypeID And SalesmanID > 0
	Else
		Insert Into @Salesman 
		Select Distinct SalesmanID From DSType_Master Mast, DSType_Details Det 
		Where Mast.DSTypeID = Det.DSTypeID And SalesmanID > 0
		And Mast.DSTypeValue In(Select * From dbo.sp_splitIn2Rows(@DSType,@Delimiter))

	Return
End
