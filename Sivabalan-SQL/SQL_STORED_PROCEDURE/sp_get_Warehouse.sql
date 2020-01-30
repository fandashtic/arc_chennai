
CREATE procedure sp_get_Warehouse as
select 
	supplyingbranch, 
	sum(isnull(PendingRequest,0) * isnull(Purchase_Price,0)) as "Value", 
	Warehouse_Name 
from 	Items, Warehouse, ItemCategories
where 	isnull(PendingRequest,0) <> 0 and
	isnull(PendingRequest,0) >= ISNULL(MinOrderQty,0) and 
	isnull(supplyingbranch,N'') <> N''  and 
	Warehouse.Active = 1 and 
	Items.Active = 1 and 
	Items.supplyingbranch = Warehouse.WarehouseID and
	Items.CategoryID = ItemCategories.CategoryID and
	ItemCategories.Track_Inventory = 1
group by supplyingbranch, Warehouse_Name



