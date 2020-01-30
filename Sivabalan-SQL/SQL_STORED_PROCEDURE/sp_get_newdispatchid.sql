
CREATE PROCEDURE sp_get_newdispatchid
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 3

