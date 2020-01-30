
CREATE PROCEDURE sp_get_VoucherPrefix(@TRANID nvarchar(50))

AS

SELECT Prefix FROM VoucherPrefix WHERE TranID = @TRANID

