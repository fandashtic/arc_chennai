

CREATE FUNCTION StripDateFromTime(@CurrentDate datetime)
RETURNS datetime
AS
BEGIN
	DECLARE @Day int
	DECLARE @Month int
	DECLARE @Year int
	SET @Day = DatePart(dd, @CurrentDate)
	SET @Month = DatePart(mm, @CurrentDate)
	SET @Year = DatePart(yyyy, @CurrentDate)
	RETURN CAST(CAST(@Day AS nvarchar) + '/' + CAST(@Month AS nvarchar) + '/' + CAST(@Year AS nvarchar) AS datetime)
END


