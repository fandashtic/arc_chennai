CREATE PROCEDURE sp_get_CountAutoPO  
  
AS  
  
Exec sp_update_OrderQty  
SELECT COUNT(Distinct (Preferred_Vendor)) FROM Items, Vendors   
WHERE OrderQty >= ISNULL(MinOrderQty,0)   
AND ISNULL(Preferred_Vendor,N'') <> N''    
AND Vendors.Active = 1 AND Items.Active = 1  
AND Items.Preferred_Vendor = Vendors.VendorID   
And OrderQty >0 And MinOrderQty >0
--GROUP BY Preferred_Vendor, Vendor_Name


