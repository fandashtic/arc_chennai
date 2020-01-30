
CREATE PROCEDURE sp_get_Disclaimer(@TRANSID NVARCHAR(50))

AS

SELECT DisclaimerText FROM Disclaimer WHERE TranID = @TRANSID

