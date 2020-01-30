
CREATE PROCEDURE sp_get_transaction_timestamp AS
SELECT TOP 1 TransactionDate FROM Setup
