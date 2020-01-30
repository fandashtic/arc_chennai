CREATE procedure [dbo].[sp_Print_StockTransferOutAbstractReceived] (@DocSerial int)
As
Select DocSerial, 
"StockTransferOut No" =  OriginalID,
"StockTransfer Date" = DocumentDate, 
"WareHouseID" = StockTransferOutAbstractReceived.WareHouseID, 
"WareHouse Name" = WareHouse.WareHouse_Name,
"Net Value" = NetValue, "Status" = Status, 
"WareHouse Address" = (Select Address + (City.CityName) + State.State +
Country.Country From WareHouse, City, State, Country 
Where WareHouse.WareHouseID = StockTransferOutAbstractReceived.WareHouseID And
WareHouse.State *= State.StateID And
WareHouse.City *= City.CityID And
WareHouse.Country *= Country.CountryID),
"Total Tax" = StockTransferOutAbstractReceived.TaxAmount,
"Goods Value" = NetValue - StockTransferOutAbstractReceived.TaxAmount
From StockTransferOutAbstractReceived, WareHouse
Where StockTransferOutAbstractReceived.DocSerial = @DocSerial And
StockTransferOutAbstractReceived.WareHouseID = WareHouse.WareHouseID
