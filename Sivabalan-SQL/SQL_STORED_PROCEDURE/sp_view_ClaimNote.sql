CREATE PROCEDURE sp_view_ClaimNote(@CLAIMID INT)      
AS      
Declare @nClaimType Integer    
Declare @InvPrefix nvarchar(10)    
Declare @ALLINVOICES As NVarchar(50)

Set @ALLINVOICES = dbo.LookupDictionaryItem(N'All Invoices', Default)
    
Set @nClaimType = (Select Isnull(ClaimType, 0) from ClaimsNote where ClaimID = @CLAIMID)    
Set @InvPrefix = (Select Prefix from VoucherPrefix WHere TranID = N'INVOICE')    
    
if @nClaimType = 6  
Begin
SELECT ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, ClaimsNote.DocumentID, ClaimType,    
DocumentReference, ClaimsNote.Status,ClaimsNote.Remarks, ClaimsNote.Balance, 
Case Isnull(DocSerialType, N'')
When N'' Then
@ALLINVOICES
Else
DocSerialType
End
FROM  ClaimsNote, Vendors, ClaimsDetail, InvoiceAbstract
WHERE ClaimsNote.ClaimID = @CLAIMID     
AND ClaimsNote.VendorID = Vendors.VendorID   
AND ClaimsNote.ClaimID = ClaimsDetail.ClaimID
AND ClaimsDetail.InvoiceID = InvoiceAbstract.InvoiceID
End
Else
Begin
SELECT ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, ClaimType,  
DocumentReference, Status,Remarks, Balance
FROM  ClaimsNote, Vendors  
WHERE ClaimID = @CLAIMID   
AND ClaimsNote.VendorID = Vendors.VendorID 
End 


