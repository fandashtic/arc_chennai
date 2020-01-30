CREATE Procedure sp_Update_WareHouse_ForumCode (@ForumCode nvarchar(20),  
      @WareHouseID nvarchar(20))  
As  
Update SRAbstractReceived Set WareHouseID = @WareHouseID   
Where ForumID = @ForumCode  
Update StockTransferOutAbstractReceived Set WareHouseID = @WareHouseID  
Where ForumCode = @ForumCode  
Update Schemes_Rec set CompanyID = @WareHouseID
Where ForumCode = @ForumCode  


