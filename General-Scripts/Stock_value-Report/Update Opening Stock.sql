Declare @TransactionDate DATETIME
Declare @Previous_TransactionDate DATETIME
DECLARE @Days INT
DECLARE @Product_Code NVARCHAR(255)
DECLARE @Batch_Number NVARCHAR(255)
DECLARE @Day INT
SET @Day = 1
DECLARE @Id INT
SET @Id = 1
Set @TransactionDate = '2019-07-01 00:00:00.000'
SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

--Declare @Items AS Table ( id Int Identity(1,1), Product_Code NVARCHAR(255), Batch_Number NVARCHAR(255))
--Insert Into @Items(Product_Code, Batch_Number)
--SELECT Distinct Product_Code, Batch_Number FROM V_ARC_Items_BatchDetails WIth (NOLOCK)

While(@Day <= @Days)
BEGIN
	PRINT cast(@Day as varchar) + '/' + cast(@Days as varchar)
	Exec ARC_Update_TransactionByDay @TransactionDate

	--SET @Id = 1
	--While(@Id <= (SELECT MAX(Id) From @Items))
	--BEGIN	
	--	SELECT @Product_Code = Product_Code, @Batch_Number = Batch_Number FROM @Items WHERE id = @Id
	--	Exec ARC_Update_TransactionByDay_Product @TransactionDate, @Product_Code, @Batch_Number
	--	SET @Id = @Id + 1
	--END

	PRINT cast(@Day as varchar) + '/' + cast(@Days as varchar)

	SET @TransactionDate = DATEADD(d, 1, @TransactionDate)
	SET @Day = @Day + 1
END
GO