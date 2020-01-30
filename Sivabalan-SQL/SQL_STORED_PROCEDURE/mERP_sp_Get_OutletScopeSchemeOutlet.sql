Create Procedure mERP_sp_Get_OutletScopeSchemeOutlet(@SchemeID Int, @GroupID Int)
As
Begin
  Select OutletID from tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID And GroupId In(
  Select SubGroupID From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
End
