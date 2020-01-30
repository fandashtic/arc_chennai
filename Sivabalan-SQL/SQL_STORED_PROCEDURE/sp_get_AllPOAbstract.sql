CREATE Procedure sp_get_AllPOAbstract (@POFromDate Datetime,@POToDate datetime)
 as 
Select Vendors.Vendor_Name, POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, POAbstract.DocumentID, POAbstract.DocumentID from 
POAbstract,Vendors
where ((POAbstract.Status & 128) = 0) and 
Vendors.VendorID=POAbstract.VendorID 
and (POAbstract.PODate between @POFromDate and @POToDate)
order by Vendors.Vendor_Name, POAbstract.PONumber
