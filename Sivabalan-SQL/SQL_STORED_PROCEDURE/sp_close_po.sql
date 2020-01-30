
CREATE PROCEDURE sp_close_po(@PONumber int)
AS
-- Implicit PO does not have pending
Update PODetail Set Pending = 0 Where PONumber = @PONumber
-- Status closed for Implicit PO 
UPDATE POAbstract SET Status = Status | 128 WHERE PONumber = @PONumber

