 --Declare @FromDate AS DATETIME
 --SET @FromDate = '04-Jan-2020'

 --select * from Setup
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-08-07 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Print @TransactionDate
	Exec ARC_Update_TransactionByDay @TransactionDate
	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END
GO
