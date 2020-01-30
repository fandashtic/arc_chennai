CREATE PROCEDURE mERP_sp_get_DocumentNumber(@DocType Int)
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = @DocType
