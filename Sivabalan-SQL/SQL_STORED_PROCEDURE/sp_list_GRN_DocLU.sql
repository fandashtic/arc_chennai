CREATE PROCEDURE sp_list_GRN_DocLU (@FromDocID int,@ToDocID int,@DocumentRef nvarchar(510)=N'')
AS
If Len(@DocumentRef)=0 
Begin
	SELECT GRNID, GRNDate, Vendors.Vendor_Name, GRNAbstract.VendorID, GRNStatus, DocumentID,
	DocumentReference,DocSerialType 
	FROM GRNAbstract, Vendors 
	WHERE GRNAbstract.VendorID = Vendors.VendorID
	AND	(DocumentID BETWEEN @FromDocID AND @ToDocID
	OR (Case Isnumeric(DocumentReference) When 1 then Cast(DocumentReference as int)end) BETWEEN @FromDocID AND @ToDocID)  
	ORDER BY Vendors.Vendor_Name, GRNDate, GRNID
end
Else
Begin
	SELECT GRNID, GRNDate, Vendors.Vendor_Name, GRNAbstract.VendorID, GRNStatus, DocumentID, 
	DocumentReference,DocSerialType
	FROM GRNAbstract, Vendors 
	WHERE GRNAbstract.VendorID = Vendors.VendorID
	And DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))) 
	When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) BETWEEN @FromDocID AND @ToDocID
	ORDER BY Vendors.Vendor_Name, GRNDate, GRNID
End




