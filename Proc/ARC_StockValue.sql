--Exec ARC_StockValue 2019
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_StockValue')
BEGIN
	DROP PROC [ARC_StockValue]
END
GO
CREATE procedure [dbo].[ARC_StockValue] (@StartYear Char(25) = 0)
As
Begin
	Declare @MonthEndDates AS TAble([Year] Nvarchar(5), [MonthName] Nvarchar(50), MonthEndDate DATETIME)
	SET @StartYear = '2019'
	Declare @I AS int = 1
	Declare @IsYes AS int = 0
	Declare @Date AS DateTime
	While(@IsYes = 0)
	Begin
		Set @Date = DateAdd(d, -1, DateAdd(m, @i, '01-Jan-'+ @StartYear))
	
		IF(DATEDIFF(d, @Date, GETDATE()) <= 1)
		BEGIN
			Set @Date = DateAdd(d, -1, Getdate())
		END

		Insert Into @MonthEndDates([Year], [MonthName], MonthEndDate)

		Select DATENAME(year,@Date), DATENAME(month,@Date), @Date
		IF(MONTH(GETDATE()) = MONTH(@Date) AND  YEAR(GETDATE()) = YEAr(@Date))
		BEGIN
			SET @IsYes = 1
		END

		SET @i = @i + 1
	END

	select	Distinct
	M.Year, M.MonthName, M.MonthEndDate TransactionDate,
	T.Product_Code,
	I.ProductName,
	T.CategoryGroup,
	T.Category,
	T.ItemFamily,
	T.ItemSubFamily,
	T.ItemGroup,
	T.Batch_Code,
	T.Batch_Number,
	T.Expairy,
	T.UOMQty,
	T.IsDamage,
	T.DamagesReason,
	T.ReceivedAgeing,
	T.Opening,
	T.Opening_Rate,
	T.Opening_Value,
	(SELECT SUM(Purchase) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Purchase,
	(SELECT SUM(Purchase_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Purchase_Value,
	--T.Purchase_Value,
	(SELECT SUM(Purchase_Discount) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Purchase_Discount,
	--T.Purchase_DiscPerUnit,
	--T.Purchase_DISCTYPE,
	--T.Purchase_InvDiscPerc,
	--T.Purchase_InvDiscAmtPerUnit,
	(SELECT SUM(Purchase_InvDiscAmount) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Purchase_InvDiscAmount,
	--T.Purchase_OtherDiscPerc,
	--T.Purchase_OtherDiscAmtPerUnit,
	(SELECT SUM(Purchase_OtherDiscAmount) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Purchase_OtherDiscAmount,
	--T.TransferIn,
	--T.TransferIn_Rate,
	(SELECT SUM(TransferIn_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) TransferIn_Value,
	(SELECT SUM(SaleReturn) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) SaleReturn,
	--T.SaleReturn_Rate,
	--T.SaleReturn_PurchaseValue,
	(SELECT SUM(SaleReturn_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) SaleReturn_Value,
	(SELECT SUM(Sales) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Sales,
	--T.Sales_Rate,
	--T.Sales_PurchaseValue,
	(SELECT SUM(Sales_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Sales_Value,
	(SELECT SUM(PruchaseReturn) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) PruchaseReturn,
	--T.PruchaseReturn_Rate,
	(SELECT SUM(PruchaseReturn_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) PruchaseReturn_Value,
	(SELECT SUM(TransferOut) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) TransferOut,
	--T.TransferOut_Rate,
	(SELECT SUM(TransferOut_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) TransferOut_Value,
	(SELECT SUM(Damage_Destroy) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Damage_Destroy,
	--T.Damage_Destroy_Rate,
	(SELECT SUM(Damage_Destroy_Value) 
		FROM TransactionByDay With (NOlock) 
		WHERE dbo.StripTimeFromDate(TransactionDate) 
		BETWEEN DATEADD(D, +1, DATEADD(M, -1,  M.MonthEndDate)) 
		AND M.MonthEndDate) Damage_Destroy_Value,
	T.Closing,
	T.Closing_Rate,
	T.Closing_Value
	Into #Temp
	from TransactionByDay T With (NOlock) 
	JOiN @MonthEndDates M ON dbo.StripTimeFromDate(M.MonthEndDate) = dbo.StripTimeFromDate(T.TransactionDate)
	JOiN Product_Mappings I With (NOlock) On I.Product_Code = T.Product_Code
	--Order By T.TransactionDate, I.ProductName ASC

	Select 1, T.* FROM #Temp T WITH (NOLOCK) Order By T.TransactionDate, T.ProductName ASC

	DROP TABLE #Temp

	Delete From @MonthEndDates
END
GO

