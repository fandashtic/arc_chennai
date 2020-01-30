

CREATE FUNCTION sp_acc_StripDateFromTime(@CurrentDate datetime)
RETURNS nvarchar(12)
AS
BEGIN
	DECLARE @Day int
	DECLARE @Month int
	DECLARE @Year int
	SET @Day = DatePart(dd, @CurrentDate)
	SET @Month = DatePart(mm, @CurrentDate)
	SET @Year = DatePart(yyyy, @CurrentDate)
	RETURN CAST(@Day AS nVARCHAR) + N'/' + CAST(@Month AS nVARCHAR) + N'/' + CAST(@Year AS nVARCHAR) 
END


