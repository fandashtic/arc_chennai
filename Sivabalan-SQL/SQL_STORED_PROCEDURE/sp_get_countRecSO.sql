
CREATE PROCEDURE sp_get_countRecSO

AS

SELECT count(*) FROM SOAbstractReceived WHERE Status = 0

