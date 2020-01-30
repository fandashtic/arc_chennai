
CREATE PROCEDURE sp_get_last_updated
AS
SELECT MAX(Opening_Date) FROM OpeningDetails

