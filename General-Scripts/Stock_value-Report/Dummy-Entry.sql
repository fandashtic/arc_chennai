Truncate table TransactionByDay
Declare @TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Day INT
SET @Day = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

While(@Day <= @Days)
BEGIN
	Insert Into TransactionByDay (TransactionDate, Product_Code,CategoryGroup,Category,ItemFamily,ItemSubFamily,ItemGroup,Batch_Number)
	select Distinct @TransactionDate, Product_Code,CategoryGroup,Category,ItemFamily,ItemSubFamily,ItemGroup,Batch_Number 
	from V_ARC_Items_BatchDetails WITH (NOLOCK)	
	--Where Product_Code = '1786' and Batch_Number = '787190169Y-280'
	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END
GO