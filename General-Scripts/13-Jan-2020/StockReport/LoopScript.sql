/*
select * from TransactionByDay With (NOlock) WHERE Product_Code = '1003' and Batch_Number = '722190141M-20' Order By 1 ASC
select top 10 Quantity, UOMQty, * from Batch_Products Where Product_Code = '1003' and Batch_Number = '722190141M-20'
Select * from V_ARC_Purchase_ItemDetails WHERE Product_Code = '1636'
Select * from V_ARC_SaleReturn_ItemDetails WHERE Product_Code = '1636'
Select * from V_ARC_Sale_ItemDetails WHERE Product_Code = '1636'
*/

Truncate table TransactionByDay
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
	--Where Product_Code = '1636' and Batch_Number = '7H1190187T-150'

	SET @Day = @Day + 1
	Set @TransactionDate = DATEADD(D,1,@TransactionDate)
END
GO

Create Table #BATCH(Id int Identity(1,1), Product_Code Nvarchar(255) , Batch_Number  Nvarchar(255))
Insert INTO #BATCH (Product_Code, Batch_Number)
select Distinct Product_Code, Batch_Number 
from Batch_Products Where ISNULL(UOMQty ,0) > 0
--AND Product_Code = '1636' and Batch_Number = '7H1190187T-150'
--select * from #BATCH

Declare @Id as Int
Set @Id = 1
Declare  @Product_Code Nvarchar(255)
Declare @Batch_Number Nvarchar(255)

While(@Id <= (Select Max(Id) From #BATCH))
BEGIN
	SELECT @Product_Code = Product_Code, @Batch_Number = Batch_Number FROM #BATCH Where Id =@Id

	Declare @TransactionDate DATETIME
	DECLARE @Days INT
	DECLARE @Day INT

	SET @Day = 1
	Set @TransactionDate = '2019-07-01 00:00:00.000'
	SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

	While(@Day <= @Days)
	BEGIN
		Print @TransactionDate
		Exec ARC_Update_TransactionByDay_Product @TransactionDate, @Product_Code, @Batch_Number
		SET @Day = @Day + 1
		Set @TransactionDate = DATEADD(D,1,@TransactionDate)
	END

	SET @Id = @Id + 1
END

Drop Table #BATCH
GO

SELECT @@SERVERNAME