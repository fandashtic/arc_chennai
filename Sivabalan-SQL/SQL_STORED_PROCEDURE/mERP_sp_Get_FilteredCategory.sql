Create Procedure mERP_sp_Get_FilteredCategory(@Level Int)
As
Begin
	Select CategoryID,Category_Name From ItemCategories Where Level = @Level And Active = 1
End
