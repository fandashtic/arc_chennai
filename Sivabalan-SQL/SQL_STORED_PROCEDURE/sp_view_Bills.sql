CREATE PROCEDURE sp_view_Bills(@VENDOR NVARCHAR(15), @FROMDATE DATETIME,
			       @TODATE DATETIME)
AS
SELECT BillAbstract.VendorID, Vendors.Vendor_Name, BillID, BillDate, 
Value +AdjustmentAmount + TaxAmount, Status, BillReference, DocumentID, 
BillAbstract.Balance,DocSerialType,DocIDReference, InvoiceReference
FROM BillAbstract, Vendors
WHERE BillAbstract.VendorID LIKE @VENDOR
AND Vendors.VendorID = BillAbstract.VendorID
AND BillDate BETWEEN @FROMDATE AND @TODATE
ORDER BY BillAbstract.VendorID, BillAbstract.BillDate


