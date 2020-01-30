CREATE procedure sp_list_vendors(@Vendor_ID as nvarchar(15), 
				 @From as datetime, 
				 @To as datetime) 
as

select GRNAbstract.VendorID as "VendorID", Vendor_Name, GRNID, 
GRNDate, VoucherPrefix.Prefix + cast(DocumentID as nvarchar)
from GRNAbstract, Vendors, VoucherPrefix 
where GRNAbstract.VendorID like @Vendor_ID 
and ((GRNStatus & 128) = 0) 
and (GRNStatus & 32 = 0)
and GRNDate Between @From And @To 
and GRNAbstract.VendorID = Vendors.VendorID 
and Vendors.Active = 1 
and VoucherPrefix.TranID = 'GOODS RECEIVED NOTE'
order by GRNAbstract.VendorID, GRNID
