Create Procedure mERP_sp_Get_CSProductScopeSKU(@SchemeID Int)
As
Begin
  Select SKUCode from tbl_mERP_SchSKUCodeScope Where SchemeID = @SchemeID
End
