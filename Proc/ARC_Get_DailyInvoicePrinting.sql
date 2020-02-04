--Exec ARC_Get_DailyInvoicePrinting '2020-02-01 00:00:00.000', '2020-02-01 00:00:00.000' 
--Exec ARC_Insert_ReportData 375, 'Daily Invoice Printing', 1, 'ARC_Get_DailyInvoicePrinting', 'Click to view Daily Invoice Printing', 70, 1, 1, 2, 0, 395, 200, 0, 0, 0, 252, 'No'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_DailyInvoicePrinting')
BEGIN
    DROP PROC ARC_Get_DailyInvoicePrinting
END
GO
CREATE Proc ARC_Get_DailyInvoicePrinting(@Fromdate DateTime, @Todate DateTime)
AS 
BEGIN
	select 1, LastPrintOn [Printing Date], DocSerialType [Van], GSTFullDocID [InvoiceId], PrintCount 
	from InvoiceAbstract WITH (NOLOCK)
	Where dbo.StripTimeFromDate(LastPrintOn) Between dbo.StripTimeFromDate(@Fromdate)
	AND dbo.StripTimeFromDate(@Todate)
	Order By LastPrintOn Asc
END
GO