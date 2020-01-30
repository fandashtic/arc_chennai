Create Procedure sp_Insert_CategoryPropRec (@ItemID int, @PropName nvarchar(255))
As
Insert Into CategoryPropReceived Values (@ItemID, @PropName)
