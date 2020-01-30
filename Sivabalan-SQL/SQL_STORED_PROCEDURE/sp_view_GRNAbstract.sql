CREATE PROCEDURE sp_view_GRNAbstract(@GRNID INT)  
As  
SELECT GRNDate, GRNAbstract.VendorID, Vendors.Vendor_Name,   
GRNAbstract.PONumbers, GRNStatus, DocRef, DocumentIDRef,  
(Select a.GRNDate From GRNAbstract a Where a.GRNID = cast(GRNAbstract.GRNIDRef as int)), Remarks,  
"DocumentReference" = Isnull(DocumentReference,N''),"DocSerialType" = Isnull(DocSerialType,N''),  
"IsRecived" =case When ISNull( RecdInvoiceID,0)=0 then 0 Else 1 End,
IsNull(InvoiceAbstractReceived.DocumentID + ' - '   + Cast(InvoiceAbstractReceived.InvoiceDate As nvarchar),''),   
"InvoiceID" = IsNull(InvoiceAbstractReceived.InvoiceID,0) 
FROM GRNAbstract Inner Join Vendors On
GRNAbstract.GRNID = @GRNID And 
GRNAbstract.VendorID = Vendors.VendorID  
Left Outer Join InvoiceAbstractReceived On
InvoiceAbstractReceived.InvoiceID = GRNAbstract.RecdInvoiceID
