CREATE procedure sp_modify_warehouse_Bunge(@WareHouseID nvarchar(25), @WareHouse_Name nvarchar (50), @Address nvarchar(255), @City int, @State int, @Country int, @ForumID nvarchar(20), @Active int, @TINNUMBER nvarchar(20) = N'', @STATEINFO Int = 0)      
as      
update stocktransferoutabstractreceived set warehouseid = @WareHouseID where docserial in ( select docserial from stocktransferoutabstractreceived where forumcode = @ForumID )      
update warehouse set  address = @address , city = @City , state = @state,      
country = @country , forumid = @forumid ,active = @active, TIN_Number = @TINNUMBER, STATEINFO = @STATEINFO       
where warehouseid = @warehouseid      
