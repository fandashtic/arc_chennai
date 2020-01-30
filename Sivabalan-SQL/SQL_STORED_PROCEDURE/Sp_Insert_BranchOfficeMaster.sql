CREATE Procedure Sp_Insert_BranchOfficeMaster  
(@szBranchID nvarchar(100), @szBranchName nvarchar(100), @szAddress nvarchar(250),
 @nCity Int, @nState Int, @nCountry Int, @szTinNumber nvarchar(100), 
 @szForumCode nvarchar(100))      
As  

if exists(select WareHouseID from WareHouse where WareHouseID = @szBranchID)  
Begin
	Update WareHouse Set WareHouse_Name = @szBranchName, Address = @szAddress, 
	City = @nCity, State = @nState, Country = @nCountry, ForumId = @szForumCode,
    TIN_Number = @szTinNumber Where WareHouseID = @szBranchID
End
Else
Begin
	Insert InTo WareHouse (WareHouseID, WareHouse_Name, Address, 
	City, State, Country, ForumId, TIN_Number) Values (@szBranchID, @szBranchName,
	@szAddress, @nCity, @nState, @nCountry, @szForumCode, @szTinNumber)
End


