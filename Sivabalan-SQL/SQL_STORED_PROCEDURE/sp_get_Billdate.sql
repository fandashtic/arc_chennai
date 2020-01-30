CREATE Procedure sp_get_Billdate (@FromDate DateTime)
As
Declare @PayDate DateTime
SELECT TOP 1 BillDate 
FROM BillAbstract 
WHERE BillAbstract.BillDate <= @FromDate and Balance > 0 And (Status & 128) = 0 ORDER BY BillAbstract.BillDate

