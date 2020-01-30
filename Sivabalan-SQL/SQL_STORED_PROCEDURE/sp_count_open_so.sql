
CREATE PROCEDURE sp_count_open_so(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT Count(*) FROM SOAbstract
WHERE SODate BETWEEN @START_DATE AND @END_DATE

