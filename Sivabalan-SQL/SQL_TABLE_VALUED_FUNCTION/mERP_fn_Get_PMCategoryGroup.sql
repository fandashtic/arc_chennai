Create Function mERP_fn_Get_PMCategoryGroup()
Returns @catGroup Table(CatGrpName nVarchar(255))
As
Begin
	

	Insert Into @CatGroup(CatGrpName) Values('GR1|GR3')
	Insert Into @CatGroup(CatGrpName) Values('GR2')

	Return 
End
