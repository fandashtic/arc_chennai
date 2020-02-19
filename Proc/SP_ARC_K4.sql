--exec SP_ARC_K4 '2020-02-04 00:00:00','2020-02-04 23:59:59'
--Exec ARC_Insert_ReportData 557, 'K4', 1, 'SP_ARC_K4', 'Click to view K4', 53, 1, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_K4')
BEGIN
    DROP PROC SP_ARC_K4
END
GO
CREATE PROCEDURE [dbo].SP_ARC_K4 (@FromDate DateTime, @ToDate DateTime)      
AS
BEGIN
	SET DATEFORMAT DMY
	select Billid, ODNumber,InvoiceReference, BillDate, I.ItemFamily, 
	SUM(OtherDiscPercAmount) [Value by Percentage Discount],
		SUM(OtherDiscAmtPerUnitAmount) [Value By Unit Discount]
	from V_ARC_Purchase_ItemDetails P WITH (NOLOCK)
	RIGHT OUTER JOIN V_ARC_Items I ON I.Product_Code = P.Product_Code
	where dbo.StripDateFromTime(BillDate) between @FromDate AND @ToDate
	group by Billid,ODNumber,InvoiceReference, BillDate, I.ItemFamily
END
GO
