
CREATE PROCEDURE sp_compute_povalue(@PONUMBER int)
AS
SELECT SUM(Pending * PurchasePrice) FROM PODetail WHERE PONumber = @PONUMBER

