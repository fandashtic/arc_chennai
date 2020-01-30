Create procedure sp_insert_warehouse_Bunge(@Warehouseid nvarchar(25), @WareHouse_Name nvarchar (50),       
@Address nvarchar(255), @City int, @State int, @Country int, @ForumID nvarchar(20), @TINNUMBER nvarchar(20) = N'', @STATEINFO Int =0)      
as      
insert into warehouse (Warehouseid , warehouse_name, address, city, state, country, forumid,active, TIN_Number, StateInfo)    values (@WareHouseID , @WareHouse_Name , @Address , @City  , @State  , @Country , @ForumID , 1, @TINNUMBER, @STATEINFO)      
