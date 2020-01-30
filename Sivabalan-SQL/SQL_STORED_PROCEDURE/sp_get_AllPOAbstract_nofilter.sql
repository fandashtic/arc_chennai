
CREATE Procedure sp_get_AllPOAbstract_nofilter (@POFromDate Datetime,@POToDate datetime)
 as 
Select Vendors.Vendor_Name, POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, status, POAbstract.DocumentID, POAbstract.Value from 
POAbstract,Vendors
where Vendors.VendorID=POAbstract.VendorID 
and (POAbstract.PODate between @POFromDate and @POToDate)
order by Vendors.Vendor_Name, POAbstract.PONumber

