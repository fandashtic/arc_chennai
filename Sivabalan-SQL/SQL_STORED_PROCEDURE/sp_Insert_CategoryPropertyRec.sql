Create Procedure sp_Insert_CategoryPropertyRec (@CategoryID int, @PropName nvarchar(255))
As
Insert Into CategoryPropertyReceived Values (@CategoryID, @PropName)

