CREATE PROCEDURE mERP_sp_get_VendorInfo_GRNBill(@VendorID nVarChar(50))
AS
Select 
VendorID,
Vendor_Name,
Locality,
CreditTerm,
BillingStateID As FromStateCode,
GSTIN As GSTIN,
IsRegistered As IsRegistered
From Vendors
Where VendorID = @VendorID
