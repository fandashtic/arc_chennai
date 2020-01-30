Create Procedure mERP_sp_GetZone(@ZoneID Int)
As
Begin
	Select ZoneID,ZoneName From tbl_mERP_Zone Where ZoneID = @ZoneID
End
