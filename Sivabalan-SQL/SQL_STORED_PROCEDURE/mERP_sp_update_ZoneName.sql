CREATE Procedure mERP_sp_update_ZoneName (@ZoneID int,  @NewName nvarchar(250))    
As    
Begin
	Update tbl_mERP_Zone  Set ZoneName = @NewName , ModifiedDate = GetDate()     
	Where ZoneID = @ZoneID
End
SET QUOTED_IDENTIFIER OFF
