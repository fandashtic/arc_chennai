Create Procedure mERP_sp_CheckValidZone(@ZoneName as nVarchar(255))
As
Begin
	Select isNull(ZoneID,0) From tbl_mERP_Zone Where Active = 1 And ZoneName = @ZoneName
End
