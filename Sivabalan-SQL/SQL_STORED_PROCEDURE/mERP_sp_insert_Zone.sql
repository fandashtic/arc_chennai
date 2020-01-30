CREATE PROCEDURE [mERP_sp_insert_Zone](@ZoneName [nvarchar](255))
AS 
	

	INSERT INTO [tbl_mERP_Zone] ([ZoneName]) 
	VALUES (@ZoneName)
	Select @@identity

	

