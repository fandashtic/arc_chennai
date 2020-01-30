CREATE procedure sp_list_Bills(@Vendor_ID nvarchar(15), @From datetime,
@To datetime) as

select BillAbstract.VendorID as "VendorID",Vendor_Name, BillID, 
BillDate, Value + AdjustmentAmount + TaxAmount, Status, BillReference,
DocumentID, BillAbstract.Balance,DocSerialType,DocIDReference, InvoiceReference
from BillAbstract, Vendors
where BillAbstract.VendorID like @Vendor_ID 
and BillAbstract.VendorID = Vendors.VendorID 
and BillDate Between @From And @To 
--and Status = 0 
--AND Value + AdjustmentAmount + TaxAmount = Balance
and Vendors.Active = 1 
order by VendorID, BillID



