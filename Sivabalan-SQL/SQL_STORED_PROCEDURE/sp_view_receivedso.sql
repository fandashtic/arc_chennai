
CREATE PROCEDURE sp_view_receivedso(@VENDORID nvarchar(15),
				   @FROMDATE datetime,
				   @TODATE datetime)

AS

Select SOAbstractReceived.VendorID, Vendors.Vendor_Name, SOAbstractReceived.SONumber,
SOAbstractReceived.SODate, Value, Status, DocumentID from SOAbstractReceived, Vendors
where Vendors.VendorID = SOAbstractReceived.VendorID
and Vendors.VendorID like @VENDORID
and (SOAbstractReceived.SODate between @FROMDATE and @TODATE)
order by Vendors.Vendor_Name, SOAbstractReceived.SODate
			

