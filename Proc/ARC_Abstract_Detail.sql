--Exec ARC_Abstract_Detail '11/2019', 'CIG'
--Exec ARC_Insert_ReportData 395, 'WD Abstract Detail', 1, 'ARC_Abstract_Detail', 'Click to view WD Abstract detail', 289, 0, 1, 2, 0, 0, 3, 1, 0, 0, 252, 'No'
--select * from ReportData Where Node like '%WD Abstract%'
--select * from ReportData where ActionData = 'spr_list_items_in_invoice_MUOM_ITC'
--select * from ReportData where ID = 23 OR Parent = 23
--select * from ParameterInfo Where ParameterID = 4
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_Abstract_Detail')
BEGIN
	DROP PROC [ARC_Abstract_Detail]
END
GO
CREATE procedure [dbo].[ARC_Abstract_Detail] (@MonthYear Nvarchar(255), @ItemFamily Nvarchar(255))
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
	Declare @Percentage As Decimal(18,6)


	SET @Percentage = (CASE WHEN CAST(@ItemFamily AS VARCHAR) = 'CIG' THEN 1.45 WHEN CAST(@ItemFamily AS VARCHAR) = 'FOOD ' THEN 2.8 WHEN CAST(@ItemFamily AS VARCHAR) = 'PCP' THEN 3.3 ELSE 0 END)
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

	Select DISTINCT S.Product_Code, I.ProductName, I.ItemFamily, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(GrossAmount) GrossAmount, SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) SaleOnPTS
	INTO #Sales
			From V_ARC_Sale_ItemDetails S With (NOLOCK)
			FULL OUTER JOIN V_ARC_Items I With (NOLOCK) ON I.Product_Code = S.Product_Code 
			Where 
			dbo.StripTimeFromDate(InvoiceDate) Between 			
			dbo.StripTimeFromDate(@MonthStartDate) AND 
			dbo.StripTimeFromDate(DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate))
			--Month(InvoiceDate) = 11 
			AND I.ItemFamily = @ItemFamily
			GROUP BY S.Product_Code, I.ProductName, I.ItemFamily

	Select DISTINCT S.Product_Code, I.ProductName, I.ItemFamily, SUM(Quantity) Quantity, SUM(Amount) NetAmount, SUM(GrossAmount) GrossAmount, SUM(ISNULL(Quantity, 0) * ISNULL(PurchasePrice, 0)) SaleOnPTS
	Into #SalesReturn
			From V_ARC_SaleReturn_ItemDetails S With (NOLOCK)
			FULL OUTER JOIN V_ARC_Items I With (NOLOCK) ON I.Product_Code = S.Product_Code 
			Where
			dbo.StripTimeFromDate(InvoiceDate) Between 			
			dbo.StripTimeFromDate(@MonthStartDate) AND 
			dbo.StripTimeFromDate(DateAdd(d,(Case WHEN ISNULL(@IsCurrentMonth, 0) = 0 THEN 0 ELSE 1 END), @MonthEndDate))
			--Month(InvoiceDate) = 11 
			AND I.ItemFamily = @ItemFamily
			GROUP BY S.Product_Code, I.ProductName, I.ItemFamily

	--Select * from #Sales
	--Select * from #SalesReturn

	DECLARE @Table AS TABLE (Product_Code NVARCHAR(255), ProductName NVARCHAR(255))

	INSERT INTO @Table(Product_Code, ProductName)
	Select Distinct Product_Code, ProductName FROM #Sales
	UNION Select Distinct Product_Code, ProductName FROM #SalesReturn

	SELECT T.Product_Code, T.ProductName,
	S.Quantity [Sale Quantity], S.GrossAmount [Sale On PTR], S.SaleOnPTS [Sale On PTS],
	SR.Quantity [Sale Return Quantity], SR.GrossAmount [Sale Return On PTR], SR.SaleOnPTS [Sale Return On PTS],

	(ISNULL(S.Quantity, 0) - ISNULL(SR.Quantity, 0)) [Total Sale Quantity],
	(ISNULL(S.GrossAmount, 0) - ISNULL(SR.GrossAmount, 0)) [Total Sale On PTR],
	(ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) [Total Sale On PTS],

	(ISNULL(S.GrossAmount, 0) - ISNULL(SR.GrossAmount, 0)) - (ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) [Gross Profit]

	--(ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) * ( @Percentage / 100) [% Margin],

	--(ISNULL(S.GrossAmount, 0) - ISNULL(SR.GrossAmount, 0)) - (ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) - 
	--(ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) * ( @Percentage / 100)	[Diff On Margin],
	
	--(ISNULL(S.GrossAmount, 0) - ISNULL(SR.GrossAmount, 0)) - (ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) - 
	--(ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) * ( @Percentage / 100)
	--/
	--(ISNULL(S.SaleOnPTS, 0) - ISNULL(SR.SaleOnPTS, 0)) * ( @Percentage / 100) 
	--[Growth %]

	INTO #Temp

	FROM 
	@Table T 
	FULL OUTER JOIN #Sales S ON S.Product_Code = T.Product_Code
	FULL OUTER JOIN #SalesReturn SR ON SR.Product_Code = T.Product_Code

	SELECT *, 
	([Total Sale On PTS] * (@Percentage / 100)) [% Margin],
	([Gross Profit] - ([Total Sale On PTS] * (@Percentage / 100))) [Diff On Margin],
	([Gross Profit] - ([Total Sale On PTS] * (@Percentage / 100))) / ([Total Sale On PTS] * (@Percentage / 100)) [Growth %]
	FROM #Temp

	DROP TABLE #Sales
	DROP TABLE #SalesReturn
	DROP TABLE #Temp

END
GO