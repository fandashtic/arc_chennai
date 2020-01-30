CREATE procedure sp_list_products(@Vendor_ID nVarChar(15)) as
select Product_code, ProductName, OrderQty, Purchase_Price, 
OrderQty * Purchase_Price AS "Amount" 
from Items, ItemCategories
where Preferred_Vendor = @Vendor_ID and 
ISNULL(OrderQty, 0) <> 0 and
ISNULL(OrderQty,0) >= ISNULL(MinOrderQty, 0) AND 
Items.Active = 1 and
Items.CategoryID = ItemCategories.CategoryID and
ItemCategories.Track_Inventory = 1
And MinOrderQty > 0

