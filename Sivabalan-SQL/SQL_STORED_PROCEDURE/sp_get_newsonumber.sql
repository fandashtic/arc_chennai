
CREATE PROCEDURE sp_get_newsonumber
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 2

