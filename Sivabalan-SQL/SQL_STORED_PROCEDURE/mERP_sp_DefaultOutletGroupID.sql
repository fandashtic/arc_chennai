Create Procedure mERP_sp_DefaultOutletGroupID(@SchemeID Int)
As
Begin
	Select isNull(Min(GroupID),0) From tbl_mERP_SchemeSubGroup Where SchemeID =  @SchemeID
End
