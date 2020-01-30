
CREATE procedure sp_get_POAbstract_nofilter (@VendorID nvarchar (15),@POFromDate datetime,@POToDate datetime)
as 
Select Vendors.Vendor_Name,POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, status, POAbstract.DocumentID, POAbstract.Value from 
POAbstract,Vendors
where Vendors.VendorID=POAbstract.VendorID 
and POAbstract.VendorID = @VendorID
and (POAbstract.PODate between @POFromDate and @POToDate)
order by POAbstract.PONumber, POAbstract.PODate

