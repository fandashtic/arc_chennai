--Exec ARC_StockValue_Update '08/2019'
--Exec ARC_StockValue_Update '09/2019'
--exec ARC_StockValue_Update '01/2020'
--Exec ARC_Insert_ReportData 292, 'WD Abstract', 1, 'ARC_StockValue_Update', 'Click to view WD Abstract', 151, 500, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_StockValue_Update')
BEGIN
	DROP PROC [ARC_StockValue_Update]
END
GO
CREATE procedure [dbo].[ARC_StockValue_Update] (@MonthYear Nvarchar(255))
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

	SET @MonthName = dbo.fn_Arc_GetMonthName(@Month);
	SET @MonthStartDate = Cast('01-'+ @MonthName +'-'+ CAST(@Year as varchar) as DateTime)
	SET @MonthEndDate = DateAdd(d, -1, DateAdd(m, 1, @MonthStartDate))
	
	IF(Day(Getdate()) < Day(@MonthEndDate) AND MONTH(Getdate()) = MONTH(@MonthEndDate) AND YEAR(Getdate()) = YEAR(@MonthEndDate))
	BEGIN
		SET @MonthEndDate = DateAdd(d, -2, Getdate());
	END

	select 
		I.*, 
		O.Opening_Quantity [Opening_Quantity], O.Opening_Value [Opening_Value], 
		P.Quantity [Purchase_Quantity], P.Amount [Purchase_Value],P.NetAmount [Purchase_WithTax_Value],
		S.Quantity [Sales_Quantity], S.GrossAmount [Sales_Value], S.NetAmount [Sales_WithTax_Value], 
		SR.Quantity [SalesReturn_Quantity], SR.GrossAmount [SalesReturn_Value], SR.NetAmount [SalesReturn_WithTax_Value], 
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
		Select Product_Code, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(GrossAmount) GrossAmount
		From V_ARC_Sale_ItemDetails With (NOLOCK) 
		Where dbo.StripTimeFromDate(InvoiceDate) Between dbo.StripTimeFromDate(@MonthStartDate) AND dbo.StripTimeFromDate(@MonthEndDate) GROUP BY Product_Code) S ON S.Product_Code = I.Product_Code
	FULL Outer Join (
		Select Product_Code, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(GrossAmount) GrossAmount
		From V_ARC_SaleReturn_ItemDetails With (NOLOCK) 
		Where dbo.StripTimeFromDate(InvoiceDate) Between dbo.StripTimeFromDate(@MonthStartDate) AND dbo.StripTimeFromDate(@MonthEndDate) GROUP BY Product_Code) SR ON SR.Product_Code = I.Product_Code


	Select 1, @Year [Year], @MonthName [Month], ItemFamily, 
	Sum([Opening_Quantity]) [Opening_Quantity],  Sum([Opening_Value]) [Opening_Value],
	Sum([Purchase_Quantity]) [Purchase_Quantity], Sum([Purchase_Value]) [Purchase_Value], Sum([Purchase_WithTax_Value]) [Purchase_WithTax_Value], 
	Sum([Sales_Quantity]) [Sales_Quantity], Sum([Sales_Value]) [Sales_Value], Sum([Sales_WithTax_Value]) [Sales_WithTax_Value], 
	Sum([SalesReturn_Quantity]) [SalesReturn_Quantity], Sum([SalesReturn_Value]) [SalesReturn_Value], Sum([SalesReturn_WithTax_Value]) [SalesReturn_WithTax_Value], 
	Sum([Closing_Quantity]) [Closing_Quantity], Sum([Closing_Value]) [Closing_Value] 
	FROM #Stocks Group By ItemFamily

	Drop Table #Stocks
END
GO

