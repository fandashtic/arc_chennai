Create Procedure mERP_sp_GetMinRange(@SchemeID Int)
As
Begin
	select Top 1 Isnull(IsMinQTY,0) IsMinQTY from tbl_merp_schemeAbstract where schemeid = @SchemeID
End
