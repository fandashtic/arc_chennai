Create Procedure mERP_sp_Get_OutletScopeSchemeChannel(@SchemeID Int, @GroupID Int)
As
Begin
  Select Channel from tbl_mERP_SchemeChannel Where SchemeID = @SchemeID And GroupId In(
  Select SubGroupID From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
End
