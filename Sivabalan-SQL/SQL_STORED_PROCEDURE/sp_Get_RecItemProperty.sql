CREATE PROCEDURE sp_Get_RecItemProperty(@ItemID int, @PropertyName nvarchar(255))
AS
SELECT ItemPropReceived.PropertyValue 
FROM ItemPropReceived
WHERE ItemPropReceived.ItemID = @ItemID And
ItemPropReceived.PropertyName = @PropertyName
