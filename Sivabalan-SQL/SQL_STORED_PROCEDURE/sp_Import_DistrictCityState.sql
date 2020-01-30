Create Procedure sp_Import_DistrictCityState (@CityID Int, @StateID Int, @DistrictID Int)
As
-- Declare @City Varchar(120)
-- Declare @DistrictID Int
-- 
-- Select @City = CityName From City Where CityID = @CityID
-- If Not Exists(Select * From District Where DistrictName = @City)
-- Begin
-- 	Insert Into District (DistrictName) Values (@City)
-- 	Select @DistrictID = @@Identity	
-- End
-- Else
-- Begin
-- 	Select @DistrictID = DistrictID From District Where DistrictName = @City
-- End

Update City Set DistrictID = @DistrictID,  StateID = @StateID Where CityID = @CityID

