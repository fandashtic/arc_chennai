Create Procedure Sp_Check_BrchCode
(@szBranchID nvarchar(100), @szBranchName nvarchar(100), @szForumCode nvarchar(100))
As  
Declare @i Int  
Set @i = 0

if exists(select WareHouseID from WareHouse where WareHouseID= @szBranchID)  
Begin
	if exists(Select WareHouse_Name From WareHouse Where WareHouseID <> @szBranchID And
	WareHouse_Name = @szBranchName)
	Begin
		Set @i = 1
	End
	Else
	Begin
		If Exists(Select ForumID From WareHouse Where WareHouseID <> @szBranchID And
		ForumID = @szForumCode)
		Begin
			Set @i = 1
		End
	End
End
Else
Begin
	if exists(Select WareHouse_Name from WareHouse Where WareHouse_Name = @szBranchName)
	Begin
		Set @i = 1
	End
	Else
	Begin
		If Exists(Select ForumID From WareHouse Where ForumID = @szForumCode)
		Begin
			Set @i = 1
		End
	End
End
Select @i


