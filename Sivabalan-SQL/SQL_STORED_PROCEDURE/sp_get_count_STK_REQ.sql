
CREATE PROCEDURE sp_get_count_STK_REQ  
AS  
Exec sp_update_RequestQty  
SELECT COUNT(Distinct (Preferred_Vendor)) FROM Items, Warehouse   
WHERE PendingRequest > ISNULL(MinOrderQty,0)   
AND ISNULL(SupplyingBranch,N'') <> N''    
AND Warehouse.Active = 1 AND Items.Active = 1  
AND Items.SupplyingBranch = Warehouse.WarehouseID   

