CREATE Procedure sp_Print_StockTransferInAbstract (@DocSerial int)    
As    
  
Declare @ItemCount int  
select @ItemCount=count(*) from StockTransferInDetail, items , ItemCategories  
Where StockTransferInDetail.Product_Code = Items.Product_Code and   
Items.CategoryID  = ItemCategories.CategoryID and  
StockTransferInDetail.DocSerial  = @DocSerial 
  
Select "Doc Serial" = DocSerial,     
"StockTransferIn No" =  IsNull(DocPrefix, N'') + Cast(DocumentID as nvarchar),    
"StockTransfer Date" = DocumentDate,     
"WareHouseID" = StockTransferInAbstract.WareHouseID,     
"WareHouse Name" = WareHouse.WareHouse_Name,    
"Net Value" = NetValue, "Status" = Status, "Reference" = ReferenceSerial,     
"Item Count" = @ItemCount,  
"WareHouse Address" = (Select Address + N' ' + Isnull(City.CityName, N'') + N' ' + Isnull(State.State, N'')  + N' ' + Isnull(Country.Country, N'')   
From WareHouse
Left Outer Join  City On WareHouse.City = City.CityID
Left Outer Join State On WareHouse.State = State.StateID
Left Outer Join Country On WareHouse.Country = Country.CountryID    
Where WareHouse.WareHouseID = StockTransferInAbstract.WareHouseID),    
"Total Tax" = StockTransferInAbstract.TaxAmount,    
"TIN Number" = TIN_Number    
From StockTransferInAbstract, WareHouse    
Where StockTransferInAbstract.DocSerial = @DocSerial And    
StockTransferInAbstract.WareHouseID = WareHouse.WareHouseID    
