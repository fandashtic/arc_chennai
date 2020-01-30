CREATE procedure spc_claims (@Start_Date datetime, @End_Date datetime)
as
select ClaimID, ClaimDate, ClaimsNote.CreationDate, Vendors.AlternateCode, ClaimType, 
Status, DocumentID, ClaimValue, SettlementType, SettlementDate, SettlementValue, 
DocumentReference
From ClaimsNote, Vendors
Where Claimdate Between @Start_Date And @End_Date And
ClaimsNote.VendorID = Vendors.VendorID
