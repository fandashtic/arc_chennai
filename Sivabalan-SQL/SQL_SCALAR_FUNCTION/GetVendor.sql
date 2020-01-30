CREATE Function GetVendor(@billid integer,@mode int =0)
returns nvarchar(255)
as
begin
DECLARE @vendor nvarchar(255)
If @mode = 0 
Begin
	select @vendor = [Vendors].[Vendor_Name] from BillAbstract,Vendors 
	where [BillID]= @billid and [BillAbstract].[VendorID]= [Vendors].[VendorID]
End
Else If @mode = 1
Begin
	select @vendor = [Vendors].[Vendor_Name] from AdjustmentReturnAbstract,Vendors 
	where [AdjustmentID]= @billid and [AdjustmentReturnAbstract].[VendorID]= [Vendors].[VendorID]
End
return @vendor
end
