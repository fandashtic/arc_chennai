IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_ReRunOpeningStock')
BEGIN
	DROP PROC [ARC_ReRunOpeningStock]
END
GO
CREATE procedure [dbo].[ARC_ReRunOpeningStock]
As
Begin

	DECLARE @Items AS TABLE (ID INT IDENTITY(1,1), Product_Code NVARCHAR(255))
	INSERT INTO @Items(Product_Code)
	SELECT Distinct  Product_Code FROM Items WITH (NOLOCK)

	Declare @TransactionDate DATETIME
	Declare @Product_Code NVARCHAR(255)
	DECLARE @Days INT
	DECLARE @Day INT
	DECLARE @ID INT
	SET @Day = 1
	Set @TransactionDate = '2019-07-01 00:00:00.000'
	SET @Days = DATEDIFF(day, @TransactionDate, Getdate())

	While(@Day <= @Days)
	BEGIN
		SET @ID = 1
		WHILE(@ID <= (SELECT MAX(ID) FROM @Items))
		BEGIN
			SELECT @Product_Code = Product_Code FROM @Items WHERE ID = @ID
			IF(ISNULL(@Product_Code,'') <> '')
			BEGIN
				PRINT CONVERT(NVARCHAR(10), @TransactionDate , 105) + ' # ' + @Product_Code 
				exec sp_update_openingdetails_ItemWise @TransactionDate, @Product_Code
			END
			SET @ID = @ID + 1
		END
		SET @TransactionDate = DATEADD(d, +1, @TransactionDate)
		SET @Day = @Day + 1
	END
END
	GO