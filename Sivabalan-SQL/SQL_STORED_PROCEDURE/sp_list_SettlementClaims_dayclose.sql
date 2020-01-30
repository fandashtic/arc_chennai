CREATE procedure sp_list_SettlementClaims_dayclose (@VendorID nvarchar(15) , @ClDate datetime)  
as  
Select ClaimsNote.VendorID, Vendors.Vendor_Name, DocumentID, ClaimDate, ClaimValue,  
ClaimID  
From ClaimsNote, Vendors  
Where ClaimsNote.VendorID like @VendorID And  
ClaimsNote.VendorID = Vendors.VendorID And  
ISNULL(ClaimsNote.SettlementType, 0) = 0 And  ClaimsNote.ClaimDate = @ClDate And
(ClaimsNote.Status & 192) = 0  
Order By ClaimsNote.VendorID, ClaimDate  


