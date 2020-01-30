Create Procedure mERP_sp_Modify_Zone(@ZoneID INT,@ACTIVE INT)
AS
Update tbl_mERP_Zone  Set Active = @ACTIVE ,ModifiedDate = GetDate() where ZoneID = @ZoneID
