
CREATE procedure sp_list_STK_REQ_products(@Warehouse_ID nVarChar(15)) as
select Product_code, ProductName, PendingRequest, Purchase_Price, 
PendingRequest * Purchase_Price AS "Amount" 
from Items, ItemCategories
where SupplyingBranch = @Warehouse_ID and 
ISNULL(PendingRequest, 0) <> 0 and
ISNULL(PendingRequest,0) >= ISNULL(MinOrderQty, 0) AND 
Items.Active = 1 and
Items.CategoryID = ItemCategories.CategoryID and
ItemCategories.Track_Inventory = 1




