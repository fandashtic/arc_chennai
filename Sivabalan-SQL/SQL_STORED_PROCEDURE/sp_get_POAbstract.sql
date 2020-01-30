CREATE procedure sp_get_POAbstract (@VendorID nVarchar (15),@POFromDate datetime,@POToDate datetime)
as 
Select Vendors.Vendor_Name,POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, POAbstract.DocumentID, POAbstract.DocumentID from 
POAbstract,Vendors
where ((POAbstract.Status & 128) = 0) and  
Vendors.VendorID=POAbstract.VendorID 
and POAbstract.VendorID = @VendorID
and (POAbstract.PODate between @POFromDate and @POToDate)
order by POAbstract.PONumber, POAbstract.PODate
