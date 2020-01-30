Create Procedure spr_Vendor_Rating (@FromDate datetime,
				    @ToDate datetime)
As
Select Vendors.VendorID,
"VendorID" = Vendors.VendorID,
"Name" = Vendors.Vendor_Name,
"Contact Person" = Vendors.ContactPerson,
"Rating" = Vendors.VendorRating
From Vendors

