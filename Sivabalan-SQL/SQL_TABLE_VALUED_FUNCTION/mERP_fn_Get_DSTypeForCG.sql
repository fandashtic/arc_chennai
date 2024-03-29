Create Function mERP_fn_Get_DSTypeForCG(@CG nVarchar(4000))
Returns @DSType Table(DSTypeValue nVarchar(50))
As
Begin
	Declare @Delimiter as nVarchar(1)
	Set @Delimiter = ','

	If @CG = N'All' Or @CG = '%%'
		Insert Into @DSType
		Select Distinct DSTypeValue From DSType_Master Where DStypeCtlPos = 1
	Else
	Begin
		Set @CG = Replace(@CG,'|',',')
		Insert Into @DSType
		Select Distinct DSTypeValue From DSType_Master Mast,tbl_mERP_DSTypeCGMapping CGMap,
		ProductCategoryGroupAbstract PCGA
		Where Mast.DStypeCtlPos = 1 And Mast.DSTypeID = CGMap.DStypeID
		And CGMap.GroupID = PCGA.GroupID
		And PCGA.GroupName In(Select * From dbo.sp_splitIn2Rows(@CG,@Delimiter))
	End

	Return
End
