Create Procedure mERP_sp_Get_CSProductScopeSubCategory(@SchemeID Int)
As
Begin
  Select SubCategory from tbl_mERP_SchSubCategoryScope Where SchemeID = @SchemeID
End
