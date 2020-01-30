create Procedure sp_update_BranchOfficeName (@WarehouseID nvarchar(20),    
         @NewName nvarchar(128))    
As    
Update WareHouse  Set WareHouse_name  = @NewName  
Where WareHouseID = @WareHouseID    


