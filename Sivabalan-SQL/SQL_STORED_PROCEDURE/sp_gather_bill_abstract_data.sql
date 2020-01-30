CREATE PROCEDURE sp_gather_bill_abstract_data(@START_DATE datetime,
	 				      @END_DATE datetime)
AS
SELECT BillID, BillDate, CreationTime, Vendors.AlternateCode, Status, DocumentID, 
InvoiceReference, BillReference, NewGRNID, DocumentReference, Value, TaxAmount,
AdjustmentAmount, Balance, UserName, Discount, DiscountOption
FROM BillAbstract, Vendors
WHERE BillDate BETWEEN @START_DATE AND @END_DATE AND
BillAbstract.VendorID = Vendors.VendorID
