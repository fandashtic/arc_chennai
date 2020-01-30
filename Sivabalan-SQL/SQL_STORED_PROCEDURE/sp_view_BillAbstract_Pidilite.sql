CREATE PROCEDURE sp_view_BillAbstract_Pidilite(@BILLID INT)      
AS      
SELECT BillID, BillDate, BillAbstract.VendorID, Vendors.Vendor_Name, Value,      
Status, InvoiceReference, BillReference, GRNID, DocumentID, NewGRNID, DocumentReference,      
TaxAmount, AdjustmentAmount, Discount, DiscountOption, Balance, PaymentID,   
Remarks, IsNull(BillAbstract.CreditTerm, -1),   
Case When PaymentDate Is Null Then BillDate Else PaymentDate End,  
Flags,DocSerialType,DocIDReference, "DiscountBeforeExcise" = IsNull(DiscountBeforeExcise,0),
AddlDiscountPercentage,AddlDiscountAmount
FROM BillAbstract, Vendors      
WHERE BillAbstract.BillID = @BILLID       
AND BillAbstract.VendorID = Vendors.VendorID      


