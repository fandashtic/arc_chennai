
CREATE PROCEDURE sp_get_PaymentCount
AS
SELECT count(*) FROM BillAbstract
WHERE PaymentDate <= getdate() and
Balance <> 0 and
Status & 128 = 0



