Create Procedure mERP_sp_Get_OutletScopeSchemeOutletClass(@SchemeID Int, @GroupID Int)
As
Begin
  Select OutletClass from tbl_mERP_SchemeOutletClass Where SchemeID = @SchemeID And GroupId In(
  Select SubGroupID From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
End
