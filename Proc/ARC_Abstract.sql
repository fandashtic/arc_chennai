--exec ARC_Abstract '08/2019'
--Exec ARC_Abstract '09/2019'
--exec ARC_Abstract '10/2019'
--exec ARC_Abstract '11/2019'
--exec ARC_Abstract '12/2019'
--exec ARC_Abstract '01/2020'
--Exec ARC_Insert_ReportData 289, 'WD Abstract', 1, 'ARC_Abstract', 'Click to view WD Abstract', 151, 500, 1, 2, 0, 395, 200, 0, 0, 0, 252, 'No'
--Update ReportData SET ActionData = 'ARC_Abstract' WHERE NODE = 'WD Abstract'
--select * from ReportData WHERE NODE = 'WD Abstract' 
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Abstract')
BEGIN
	DROP PROC [ARC_Abstract]
END
GO
CREATE procedure [dbo].[ARC_Abstract] (@MonthYear Nvarchar(255))
As
Begin	
	Declare @Month int
	Declare @Year int
	Declare @Temp as Table(id int identity(1,1), Datas Int)
	Insert Into @Temp(Datas)
	select ItemValue from dbo.[fn_SplitIn2Rows_CRN](@MonthYear, '/');
	Select @Month = Datas From @Temp Where Id = 1
	Select @Year = Datas From @Temp Where Id = 2	
	Declare @MonthEndDate DATETIME
	Declare @MonthStartDate DATETIME
	Declare @MonthName NVARCHAR(10)
	Declare @IsCurrentMonth INT

	SET @IsCurrentMonth = 0
	SET @MonthName = dbo.fn_Arc_GetMonthName(@Month);
	SET @MonthStartDate = Cast('01-'+ @MonthName +'-'+ CAST(@Year as varchar) as DateTime)
	SET @MonthEndDate = DateAdd(d, -1, DateAdd(m, 1, @MonthStartDate))
	
	IF(Day(Getdate()) < Day(@MonthEndDate) AND MONTH(Getdate()) = MONTH(@MonthEndDate) AND YEAR(Getdate()) = YEAR(@MonthEndDate))
	BEGIN
		SET @MonthEndDate = DateAdd(d, -2, Getdate());
		SET @IsCurrentMonth = 1
	END

	PRINT DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate)

	select 
		I.*, 
		O.Opening_Quantity [Opening_Quantity], O.Opening_Value [Opening_Value], 
		P.Quantity [Purchase_Quantity], P.Amount [Purchase_Value],P.NetAmount [Purchase_WithTax_Value],
		S.Quantity [Sales_Quantity], S.NetAmount [Sales_WithTax_Value], S.STPayable [S_STPayable],
		SR.Quantity [SalesReturn_Quantity], SR.NetAmount [SalesReturn_WithTax_Value], SR.STPayable [SR_STPayable],
		--(ISNULL(S.Quantity, 0) - ISNULL(SR.Quantity, 0)) [ActualSales],		
		--(ISNULL(S.GrossAmount, 0) - ISNULL(S.SaleOnPTS, 0)) [PTR_PTS],
		C.Opening_Quantity [Closing_Quantity], C.Opening_Value [Closing_Value] 
	Into #Stocks
	from V_ARC_Items I With (NOLOCK)
	Full Outer Join (Select Product_Code, Opening_Quantity, Opening_Value From OpeningDetails With (NOLOCK) Where dbo.StripTimeFromDate(Opening_Date) = dbo.StripTimeFromDate(@MonthStartDate)) O ON O.Product_Code = I.Product_Code
	Full Outer Join (Select Product_Code, Opening_Quantity, Opening_Value From OpeningDetails With (NOLOCK) Where dbo.StripTimeFromDate(Opening_Date) = dbo.StripTimeFromDate(DateAdd(d, +1, @MonthEndDate))) C ON C.Product_Code = I.Product_Code
	Full Outer Join (
		Select Product_Code, SUM(Quantity) Quantity, (SUM(NetAmount) + SUM(TaxAmount)) NetAmount, (SUM(NetAmount)) Amount
		From V_ARC_Purchase_ItemDetails With (NOLOCK) 
		Where dbo.StripTimeFromDate(BillDate) Between dbo.StripTimeFromDate(@MonthStartDate) AND dbo.StripTimeFromDate(@MonthEndDate) GROUP BY Product_Code) P ON P.Product_Code = I.Product_Code
	FULL Outer Join (
		Select Product_Code, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(STPayable) STPayable
		From V_ARC_Sale_ItemDetails With (NOLOCK) 
		Where dbo.StripTimeFromDate(InvoiceDate) Between dbo.StripTimeFromDate(@MonthStartDate) AND dbo.StripTimeFromDate(DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate)) GROUP BY Product_Code) S ON S.Product_Code = I.Product_Code
	FULL Outer Join (
		Select Product_Code, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(STPayable) STPayable
		From V_ARC_SaleReturn_ItemDetails With (NOLOCK) 
		Where dbo.StripTimeFromDate(InvoiceDate) Between dbo.StripTimeFromDate(@MonthStartDate) AND dbo.StripTimeFromDate(DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate)) GROUP BY Product_Code) SR ON SR.Product_Code = I.Product_Code
		
	--select * from #Stocks Order By ItemFamily

	Select 
	--(@MonthYear + ',''' + ItemFamily + ''''), 
	@Year [Year], @MonthName [Month], 
	CONVERT(NVARCHAR(10), @MonthStartDate, 105) [Start Date], 
	CONVERT(NVARCHAR(10), DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate), 105) [End Date],
	ItemFamily, 
	(CASE WHEN CAST(ItemFamily AS VARCHAR) = 'CIG' THEN 1.45 WHEN CAST(ItemFamily AS VARCHAR) = 'FOOD ' THEN 2.8 WHEN CAST(ItemFamily AS VARCHAR) = 'PCP' THEN 3.3 ELSE 0 END) [Margin %],
	Sum([Opening_Quantity]) [Opening_Quantity],  Sum([Opening_Value]) [Opening_Value],
	Sum([Purchase_Quantity]) [Purchase_Quantity], Sum([Purchase_Value]) [Purchase_Value], Sum([Purchase_WithTax_Value]) [Purchase_WithTax_Value], 
	 
	Sum([Sales_Quantity]) [Sales_Quantity], SUM([Sales_WithTax_Value]) [Sales_WithTax_Value], SUM([S_STPayable]) [S_STPayable],
	Sum([SalesReturn_Quantity]) [SalesReturn_Quantity], SUM([SalesReturn_WithTax_Value]) [SalesReturn_WithTax_Value], SUM([SR_STPayable]) [SR_STPayable],
	(SUM([Sales_WithTax_Value]) - SUM([S_STPayable])) [Sales]
	,(SUM([SalesReturn_WithTax_Value]) - SUM([SR_STPayable])) [Sales Return]
	,Sum([Closing_Quantity]) [Closing_Quantity], Sum([Closing_Value]) [Closing_Value]
	,((SUM([Sales_WithTax_Value]) - SUM([S_STPayable])) - (SUM([SalesReturn_WithTax_Value]) - SUM([SR_STPayable]))) [Actual Sales]
	INTO #Temp
	FROM #Stocks Group By ItemFamily

	SELECT 
	[Year], [Month], [Start Date], [End Date], [ItemFamily], [Margin %]
	,Opening_Value Opening
	,Purchase_Value Purchase
	,[Sales]
	,[Sales Return]
	,[Actual Sales]
	, Closing_Value Closing
	,((ISNULL([Actual Sales], 0) + ISNULL([Closing_Value], 0)) - (ISNULL([Purchase_Value], 0) + ISNULL([Opening_Value], 0))) [Gross Profit]
	--,([Actual Sales] * [Margin %]) [Profit By WD Margin]
	--,(((ISNULL([Actual Sales], 0) + ISNULL([Closing_Value], 0)) - (ISNULL([Purchase_Value], 0) + ISNULL([Opening_Value], 0))) - ([Actual Sales] * [Margin %])) [Diff On Margin]
	FROM #Temp WITH (NOLOCK)

	Drop Table #Stocks
END
GO

