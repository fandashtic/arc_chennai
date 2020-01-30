CREATE PROCEDURE sp_Cancel_Bills(@VENDOR NVARCHAR(15), @FROMDATE DATETIME,
			       @TODATE DATETIME)
AS
SELECT BillAbstract.VendorID, Vendors.Vendor_Name, BillID, BillDate, 
Value +AdjustmentAmount + TaxAmount, Status, BillReference, DocumentID, 
BillAbstract.Balance,DocSerialType,DocIDReference, InvoiceReference
FROM BillAbstract, Vendors
WHERE BillAbstract.VendorID LIKE @VENDOR
AND Vendors.VendorID = BillAbstract.VendorID
AND BillDate BETWEEN @FROMDATE AND @TODATE
--AND (Status & 128) = 0 -- 128 includes both amendment and cancelled bills
--AND (BillAbstract.Value + BillAbstract.AdjustmentAmount + BillAbstract.TaxAmount) = BillAbstract.Balance
ORDER BY BillAbstract.VendorID, BillAbstract.BillDate




