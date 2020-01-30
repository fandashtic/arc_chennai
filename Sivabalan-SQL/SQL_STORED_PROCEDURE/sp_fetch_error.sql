
CREATE PROCEDURE sp_fetch_error(@ERROR_ID int)
AS
SELECT Message FROM ErrorMessages WHERE ErrorID = @ERROR_ID

