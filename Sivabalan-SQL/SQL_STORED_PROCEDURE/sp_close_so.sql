

CREATE PROCEDURE sp_close_so(@SONumber int)
AS
IF (SELECT SUM(Pending) from SODetail WHERE SONumber = @SONumber) = 0
BEGIN
	UPDATE SOAbstract SET Status = Status | 128 WHERE SONumber = @SONumber
END



