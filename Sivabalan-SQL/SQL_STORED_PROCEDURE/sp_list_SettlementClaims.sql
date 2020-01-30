
CREATE procedure sp_list_SettlementClaims (@VendorID nvarchar(15),
					   @FromDate datetime,
					   @ToDate datetime)
as
Select ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, ClaimDate, ClaimValue
DocumentID
From ClaimsNote, Vendors
Where ClaimsNote.VendorID like @VendorID And
ClaimsNote.VendorID = Vendors.VendorID And
ClaimDate Between @FromDate And @ToDate And
(Status & 128) = 0


