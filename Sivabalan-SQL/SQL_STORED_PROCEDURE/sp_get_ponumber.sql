CREATE PROCEDURE sp_get_ponumber
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 1
