CREATE Procedure Sp_Insert_CityMaster  
(@szCity nvarchar(100),@szDistrict nvarchar(100),@szState nvarchar(100),
@StdCode nvarchar(12)=N'')      
as  
Declare @TempDistID int  
Declare @TempStateID int  
Declare @TempCityID int  
  
--Insert/Update District  
if exists(select DistrictName from District where DistrictName = @szDistrict)  
Select @TempDistID = DistrictID From District where DistrictName = @szDistrict  
Else  
	Begin  
		insert into District(DistrictName) values (@szDistrict)  
		Select @TempDistID = @@Identity  
	End  
--Insert/Update State  
if exists(select State from State where State = @szState)      
Select @TempStateID = StateID From State where State = @szState  
Else  
Begin  
	insert into State(State,Active) values (@szState , 1)  
	Select  @TempStateID = @@Identity  
End  
--Insert/Update City  
if exists(select CityName from city where CityName = @szCity)      
Begin  
	Update City Set DistrictID = @TempDistID , StateID = @TempStateID,STDCode = @StdCode  
	Where CityName = @szCity  
	Select @TempCityID = CityID From City Where CityName = @szCity  
	Update Customer Set District = @TempDistID,StateID = @TempStateID  
	Where CityID = @TempCityID  
End  
Else  
Begin  
	Insert Into City(CityName,DistrictID,StateID,Active,STDCode) Values(@szCity,@TempDistID,@TempStateID,1, @StdCode )  
End  



