
CREATE PROCEDURE sp_count_open_grn(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT Count(*) FROM GRNAbstract
WHERE GRNDate BETWEEN @START_DATE AND @END_DATE

