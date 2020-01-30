
CREATE PROCEDURE sp_get_countRecPO

AS

SELECT count(*) FROM POAbstractReceived WHERE Status = 0

