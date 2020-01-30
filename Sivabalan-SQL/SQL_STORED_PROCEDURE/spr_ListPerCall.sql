
CREATE procedure spr_ListPerCall(@FROMDATE DATETIME,
                                 @TODATE DATETIME)
AS

Select InvoiceID,InvoiceDate,(select "Count" = COUNT(*), "Average Sales" = AVG(NetValue) from Invoicedetails where InvoiceDetail.InvoiceID=InvoiceAbstractID.InvoiceID) from InvoiceAbstract 
where InvoiceType in(1,3) AND InvoiceDate BETWEEN @FROMDATE And @TODATE


