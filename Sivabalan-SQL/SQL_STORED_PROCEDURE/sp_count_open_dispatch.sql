
CREATE PROCEDURE sp_count_open_dispatch(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT Count(*) FROM DispatchAbstract
WHERE DispatchDate BETWEEN @START_DATE AND @END_DATE


