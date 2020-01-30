
create Procedure sp_list_PO_DocLU (@DocIDFrom int, @DocIDTo int)
 as 
Select Vendors.Vendor_Name, POAbstract.PONumber,
POAbstract.PODate, POAbstract.RequiredDate, status, POAbstract.DocumentID, POAbstract.Value from 
POAbstract,Vendors
where Vendors.VendorID=POAbstract.VendorID 
and (POAbstract.DocumentID between @DocIDFrom and @DocIDTo)
order by Vendors.Vendor_Name, POAbstract.PONumber

