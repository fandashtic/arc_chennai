Create procedure sp_get_vendor as
select Preferred_Vendor, sum(OrderQty * Purchase_Price) as "Value", Vendor_Name 
from Items, Vendors, ItemCategories
where OrderQty <> 0 and
OrderQty >= ISNULL(MinOrderQty,0) and 
isnull(Preferred_Vendor,N'') <> N''  and 
Vendors.Active = 1 and 
Items.Active = 1 and 
Items.Preferred_Vendor = Vendors.VendorID and
Items.CategoryID = ItemCategories.CategoryID and
ItemCategories.Track_Inventory = 1 And
MinOrderQty >0
group by Preferred_Vendor, Vendor_Name





