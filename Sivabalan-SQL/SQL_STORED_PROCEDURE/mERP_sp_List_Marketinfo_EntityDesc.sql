Create Procedure mERP_sp_List_Marketinfo_EntityDesc(@EntityType nVarchar(25))
As
Begin
	Declare  @Return Table (District Nvarchar(255),SubDistrict Nvarchar(255),Market Nvarchar(255),PopGroup Nvarchar(255))
	If @EntityType = 'DISTRICT'
		insert into @Return (District) Select Distinct District From MarketInfo Where Active = 1 order by District
	Else if @EntityType = 'SUBDISTRICT'
		insert into @Return (District,SubDistrict) Select Distinct District, Sub_District From MarketInfo Where Active = 1 Order by District, Sub_District
	Else If @EntityType = 'MARKETBOI'
		insert into @Return (District,SubDistrict,Market) Select Distinct District,Sub_District, Cast(MarketID as nVarchar(10))+ N'-'+MarketName From MarketInfo Where Active = 1 Order by Sub_District, Cast(MarketID as nVarchar(10)) + N'-' + MarketName
	Else If @EntityType = 'POPGROUP'
		insert into @Return (Market,PopGroup) Select Distinct Cast(MarketID as nVarchar(10))+ N'-'+MarketName, Pop_Group From MarketInfo Where Active = 1 Order by Cast(MarketID as nVarchar(10))+ N'-'+MarketName , Pop_Group
	Update @Return Set SubDistrict = Null Where isnull(SubDistrict,'') = ''
	if @EntityType = 'SUBDISTRICT'
		Begin
			Update @Return Set SubDistrict = District + ' | ' + isnull(SubDistrict,'Blank') --Where isnull(SubDistrict,'') = ''
		End
 
	If @EntityType = 'POPGROUP'
		Begin
			Update @Return Set PopGroup = 'Blank' Where isnull(PopGroup,'') = ''
		End
	If @EntityType = 'MARKETBOI'
		Begin
			Update @Return Set SubDistrict = District + ' | ' + isnull(SubDistrict,'Blank') --Where isnull(SubDistrict,'') = ''
		End


	If @EntityType = 'DISTRICT'
		Select Distinct District From @Return order by District 
	Else if @EntityType = 'SUBDISTRICT'
		Select Distinct District, SubDistrict From @Return Order by District, SubDistrict
	Else If @EntityType = 'MARKETBOI'
		Select Distinct SubDistrict, Market From @Return Order by SubDistrict, Market
	Else If @EntityType = 'POPGROUP'
		Select Distinct Market,PopGroup From @Return Order by Market,PopGroup
End
