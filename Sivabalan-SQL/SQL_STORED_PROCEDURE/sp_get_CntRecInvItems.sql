
CREATE PROCEDURE sp_get_CntRecInvItems(@INVNUMBER INT)

AS

SELECT COUNT(*) FROM InvoiceDetailReceived WHERE InvoiceID = @INVNUMBER

