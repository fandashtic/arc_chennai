Create Procedure mERP_sp_Get_MaxCSOutletScope(@SchemeID Int, @GroupID Int)
As
Begin
 Select Max(RowCnt) From(
 Select Count(Channel) 'RowCnt' from tbl_mERP_SchemeChannel Where SchemeID = @SchemeID 
 And GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
 Union all
 Select  Count(OutletClass) 'RowCnt' from tbl_mERP_SchemeOutletClass Where SchemeID = @SchemeID 
 And GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
  Union all
 Select  Count(OutletID) 'RowCnt' from tbl_mERP_SchemeOutlet Where SchemeID = @SchemeID 
 And GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
  Union all
 Select  Count(Loyaltyname) 'RowCnt' from tbl_mERP_SchemeLoyaltyList Where SchemeID = @SchemeID 
 And GroupID In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where SchemeID = @SchemeID And GroupID = @GroupID) 
) A
End
