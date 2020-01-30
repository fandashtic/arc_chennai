Create Procedure mERP_sp_Get_OutletScopeSchemeLoyalty(@SchemeID Int, @GroupID Int)
As
Begin
  Select Loyaltyname from tbl_mERP_SchemeLoyaltyList Where SchemeID = @SchemeID And GroupId In(
  Select SubGroupID From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID)
End
