
CREATE PROCEDURE sp_get_TempInvoiceID AS

SELECT DocumentID FROM DocumentNumbers WHERE DocType = 4

