CREATE PROCEDURE sp_view_receivedso_DocLU (@FromDocID int,
				   @ToDocID int)
AS
Select SOAbstractReceived.VendorID, Vendors.Vendor_Name, SOAbstractReceived.SONumber,
SOAbstractReceived.SODate, Value, Status, DocumentID from SOAbstractReceived, Vendors
where Vendors.VendorID = SOAbstractReceived.VendorID
and (dbo.GetTrueVal(SOAbstractReceived.DocumentID) between @FromDocID and @ToDocID)
order by Vendors.Vendor_Name, SOAbstractReceived.SODate
