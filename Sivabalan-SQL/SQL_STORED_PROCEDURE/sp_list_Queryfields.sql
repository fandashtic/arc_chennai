
CREATE PROCEDURE sp_list_Queryfields (@TABLE_ID INT)
AS
SELECT FieldName, DisplayName, HasLookUp, LookUpTable,
KeyField, DisplayField, Delimiter FROM QueryFields WHERE TableID = @TABLE_ID ORDER BY ID



