
CREATE PROCEDURE sp_get_CountPO

AS

SELECT COUNT(*) FROM POAbstract
WHERE Status & 128 = 0 
AND POAbstract.RequiredDate <= getdate()


