CREATE PROCEDURE sp_list_Claims_DocLU_Cancel (@FromDocID int, @ToDocID int)  
AS  
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID,   
Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue  
FROM ClaimsNote, Vendors  
WHERE ClaimsNote.VendorID = Vendors.VendorID  
AND DocumentID BETWEEN @FromDocID AND @ToDocID  
AND ClaimsNote.Status & 192 = 0   
AND Isnull(Status, 0) & 1 = 0   
And ClaimType In(1,3)
union
SELECT ClaimID, ClaimDate, ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID,   
Case Balance When 0 Then Status | 128 Else Status End, Balance, ClaimValue  
FROM ClaimsNote, Vendors  
WHERE ClaimsNote.VendorID = Vendors.VendorID  
AND DocumentID BETWEEN @FromDocID AND @ToDocID  
AND ClaimsNote.Status & 192 = 0   
AND Isnull(Status, 0) & 1 = 0   
And ClaimType In(2)
And ClaimID not in (select distinct claimID from DandDAbstract)
Order By ClaimsNote.VendorID, ClaimsNote.ClaimDate  
