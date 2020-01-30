Create Procedure mERP_sp_Get_GroupWiseOutletScope(@SchemeID Int,@GroupID Int)
As
Begin
	Select 
		Distinct Chn.Channel,Olclass.OutletClass,Loyalty.Loyaltyname,Outlet.OutletID ,Chn.GroupId
	From
		tbl_mERP_SchemeChannel Chn, tbl_mERP_SchemeOutletClass  Olclass,
		tbl_mERP_SchemeLoyaltyList Loyalty, tbl_mERP_SchemeOutlet Outlet
	Where 
		Chn.SchemeID = @SchemeID And 
		Chn.GroupId In(Select SubGroupID From tbl_mERP_SchemeSubGroup Where GroupID = @GroupID And SchemeID = @SchemeID) And
		Olclass.SchemeID = Chn.SchemeID And
		Olclass.GroupId = Chn.GroupId And
		Loyalty.SchemeID = Chn.SchemeID And
		Loyalty.GroupId = Chn.GroupId And
		Outlet.SchemeID = Chn.SchemeID And
		Outlet.GroupId = Chn.GroupId 
End
