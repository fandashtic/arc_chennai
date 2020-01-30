
CREATE PROCEDURE sp_get_TempBillNo
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 6

