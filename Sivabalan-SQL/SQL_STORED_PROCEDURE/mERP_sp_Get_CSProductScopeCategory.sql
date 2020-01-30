Create Procedure mERP_sp_Get_CSProductScopeCategory(@SchemeID Int)
As
Begin
  Select Category from tbl_mERP_SchCategoryScope Where SchemeID = @SchemeID
End
