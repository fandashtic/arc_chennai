
CREATE PROCEDURE sp_get_newInvoiceID
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 4

