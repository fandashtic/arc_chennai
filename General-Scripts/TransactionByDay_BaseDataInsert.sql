--select * from Setup
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Insert Into TransactionByDay (TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number)
	select Distinct @TransactionDate, Product_Code,CategoryGroup,Brand,Varient,Category,Family,Batch_Code,Batch_Number from V_ARC_Items_BatchDetails WITH (NOLOCK)

	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END

--Truncate table TransactionByDay