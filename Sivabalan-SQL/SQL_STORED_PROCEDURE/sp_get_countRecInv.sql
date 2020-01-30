
CREATE PROCEDURE sp_get_countRecInv

AS

SELECT count(*) FROM InvoiceAbstractReceived WHERE Status = 0

