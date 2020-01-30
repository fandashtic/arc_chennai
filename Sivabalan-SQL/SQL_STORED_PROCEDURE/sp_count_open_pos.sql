
CREATE PROCEDURE sp_count_open_pos(@START_DATE datetime,
						     @END_DATE datetime)
AS
SELECT Count(*) FROM POAbstract
WHERE PODate BETWEEN @START_DATE AND @END_DATE

