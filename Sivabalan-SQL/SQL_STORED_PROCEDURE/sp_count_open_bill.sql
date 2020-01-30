
CREATE PROCEDURE sp_count_open_bill(@START_DATE datetime,
					    @END_DATE datetime)
AS
SELECT Count(*) FROM BillAbstract
WHERE BillDate BETWEEN @START_DATE AND @END_DATE

