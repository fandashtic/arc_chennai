CREATE PROCEDURE sp_view_Bills_DocLU (@FromDocID int, @ToDocID int,@DocumentRef nvarchar(510)=N'')
AS
If Len(@DocumentRef)=0 
Begin
	SELECT BillAbstract.VendorID, Vendors.Vendor_Name, BillID, BillDate, 
	Value +AdjustmentAmount + TaxAmount, Status, BillReference, DocumentID, 
	BillAbstract.Balance,DocSerialType,DocIDReference, InvoiceReference
	FROM BillAbstract, Vendors
	WHERE Vendors.VendorID = BillAbstract.VendorID
	AND	(DocumentID BETWEEN @FromDocID AND @ToDocID
	OR (Case Isnumeric(DocIDReference) When 1 then Cast(DocIDReference as int)end) BETWEEN @FromDocID AND @ToDocID)  
	ORDER BY BillAbstract.VendorID, BillAbstract.BillDate
End
Else
Begin
	SELECT BillAbstract.VendorID, Vendors.Vendor_Name, BillID, BillDate, 
	Value +AdjustmentAmount + TaxAmount, Status, BillReference, DocumentID, 
	BillAbstract.Balance,DocSerialType,DocIDReference, InvoiceReference
	FROM BillAbstract, Vendors
	WHERE Vendors.VendorID = BillAbstract.VendorID
	And DocIDReference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(DocIDReference,Len(@DocumentRef)+1,Len(DocIDReference))) 
	When 1 then Cast(Substring(DocIDReference,Len(@DocumentRef)+1,Len(DocIDReference))as int)End) BETWEEN @FromDocID AND @ToDocID
	ORDER BY BillAbstract.VendorID, BillAbstract.BillDate
End





