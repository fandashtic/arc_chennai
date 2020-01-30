CREATE PROCEDURE sp_get_stkreqnumber
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 22

