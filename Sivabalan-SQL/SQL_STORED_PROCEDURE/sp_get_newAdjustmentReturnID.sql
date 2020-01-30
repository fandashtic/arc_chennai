
CREATE PROCEDURE sp_get_newAdjustmentReturnID
AS
SELECT DocumentID FROM DocumentNumbers WHERE DocType = 9

