Create Procedure sp_Insert_ItemPropRec (@ItemID Int, @PropName nvarchar(255), @PropValue nvarchar(255))
As
Insert Into ItemPropReceived Values (@ItemID, @PropName, @PropValue)
