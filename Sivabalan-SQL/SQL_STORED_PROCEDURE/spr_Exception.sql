CREATE PROCEDURE spr_Exception(@FromDate DateTime, @ToDate DateTime)
AS
DECLARE @TempDate DateTime

CREATE TABLE #TempException(CustomerID nVarchar(50), CustomerName nVarchar(100), ReportDate DateTime)

SET @TempDate = @FromDate

WHILE @TempDate <= @ToDate
BEGIN
INSERT INTO #TempException SELECT "CustomerID" = Customer.CustomerID, "CompanyName" = Customer.Company_Name, "Report Date" = @TempDate
FROM Customer
WHERE Customer.AlterNateCode NOT IN(SELECT Rep.CompanyID FROM Reports Rep WHERE Rep.ReportDate = dbo.StripDateFromTime(@TempDate))
And Customer.Active = 1 
GROUP BY Customer.CustomerID, Customer.Company_Name
SET @TempDate = DateAdd(d,1,@TempDate)
END
SELECT "Customer ID" = CustomerID, "Customer ID" = CustomerID, "Company Name" = CustomerName, "Report Date" = ReportDate FROM #TempException
GROUP BY CustomerID, CustomerName, ReportDate

DROP TABLE #TempException








