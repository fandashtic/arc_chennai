CREATE FUNCTION GetPendingBillsForSalesman(@SALESMANID int, @FROMDATE datetime, @TODATE datetime)
RETURNS INT
AS
begin
Return (Select Count(InvoiceID) From InvoiceAbstract
		    Where InvoiceType in (1, 3) AND (Status & 128) = 0 AND  
		    InvoiceDate BETWEEN @FROMDATE AND @TODATE And 
		    Balance > 0 And SalesmanID = @SALESMANID)
end
