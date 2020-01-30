
CREATE PROC sp_get_ClaimNumber
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 7

