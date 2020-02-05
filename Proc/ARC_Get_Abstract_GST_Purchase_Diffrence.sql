--Exec ARC_Get_Abstract_GST_Purchase_Diffrence '2019-01-10 00:00:00','2019-10-31 23:59:59'
--Exec ARC_GetUnusedReportId
Exec ARC_Insert_ReportData 513, 'Abstract GST Diffrence - Purchase', 1, 'ARC_Get_Abstract_GST_Purchase_Diffrence', 'Click to view Abstract GST Diffrence - Purchase', 70, 1, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
GO
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_Abstract_GST_Purchase_Diffrence')
BEGIN
    DROP PROC ARC_Get_Abstract_GST_Purchase_Diffrence
END
GO
CREATE Proc ARC_Get_Abstract_GST_Purchase_Diffrence(@FromDate DateTime, @Todate DateTime)
AS 
BEGIN	
	SET @FromDate = dbo.StripDateFromTime(CAST(@FromDate AS DATETIME))
	SET @Todate = dbo.StripDateFromTime(CAST(@Todate AS DATETIME))
	PRINT @FromDate
	PRINT @Todate

	select 1, * FROM 
	(select FORMAT(BillDate, 'MMMM', 'en-US') [Abstract Bill Month], ODNumber [Abstract Bill No], BillDate [Abstract Bill Date], Max(BillAmount) [Abstract Bill Amount], Sum(NetAmount) [Abstract Bill Taxable Value]
	from V_ARC_Purchase_ItemDetails WITH (NOLOCK)
	Where BillDate Between @FromDate AND @Todate
	Group By ODNumber, BillDate) A
	FULL OUTER JOIN (
	select 
	 FORMAT(InvoiceDate, 'MMMM', 'en-US') [GST Bill Month],
	InvoiceNo [GST Bill No],
	InvoiceDate	[GST Bill Date],
	InvoiceValue [GST Bill Amount],
	TaxableValue [GST Bill Taxable Value]
	from dbo.fn_Arc_Get_GSTPurchase(@FromDate,@Todate)
	)
	G On G.[GST Bill No] = A.[Abstract Bill No]
	--WHERE MONTH([Abstract Bill Date]) <> MONTH([GST Bill Date])
	--Order By [GST Bill Date] ASC
END
GO
