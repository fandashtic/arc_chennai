CREATE Procedure sp_get_WareHouseInfo (@WareHouseID nvarchar(25))
As
Select Address + char(13) + char(10) + IsNull(City.CityName, N'') +
char(13) + char(10) + IsNull(State.State, N'') + char(13) + char(10) +
IsNull(Country.Country, N'')
,BillingStateID, GSTIN, IsRegistered
From WareHouse
Left Outer Join City On  WareHouse.City = City.CityID
Left Outer Join State On WareHouse.State = State.StateID
Left Outer Join Country On WareHouse.Country = Country.CountryID
Where WareHouseID = @WareHouseID 
