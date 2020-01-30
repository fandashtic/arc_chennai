
Create Function mERP_fn_GetCategory(@Hierarchy nVarchar(50))
Returns @Category Table (Category nVArchar(255))
As
Begin

	Insert Into @Category Select CategoryID From ItemCategories
		Where [Level] In (Select HierarchyID From ItemHierarchy
				Where HierarchyName = @Hierarchy )
	Return
End

