CREATE Procedure sp_Han_Asset_Validation(@CustomerID nVarchar(20), @SalesmanID int, @AssetType nVarchar(100), 
											@AssetNumber nVarchar(50), @AssetStatus nVarchar(20), @Source nVarchar(20))
As  
Declare @ErrorMsg nVarchar(100)
Declare @ExistAssetType nVarchar(100)
Declare @ExistCustomerID nVarchar(20)
Declare @Active int

Set @ErrorMsg = ''
Set @ExistAssetType = ''
Set @ExistCustomerID = ''
Set @Active = 1

-- To check whether data is empty or not
IF @CustomerID = ''
Begin
	Set @ErrorMsg = 'CustomerID is empty.'
	Goto Out
End
Else if @AssetNumber = ''
Begin
	Set @ErrorMsg = 'Asset Number is empty.'
	Goto Out
End
Else if @SalesmanID <= 0
Begin
	Set @ErrorMsg = 'SalesmanID is empty.'
	Goto Out
End
Else if @AssetStatus = ''
Begin
	Set @ErrorMsg = 'Asset Status is empty.'
	Goto Out
End
Else if @Source = ''
Begin
	Set @ErrorMsg = 'Source is empty.'
	Goto Out
End

-- To check whether CustomerID Exist in Customer Master
Select @ExistCustomerID = IsNull(CustomerID, ''), @Active = IsNull(Active, 0) From Customer Where CustomerID = @CustomerID
If @ExistCustomerID = ''
Begin
	Set @ErrorMsg = 'Invalid CustomerID [' + @CustomerID + '].'
	Goto Out
End

-- To check whether Salesman Exist in Salesman Master
If Not Exists(Select SalesmanID From Salesman Where SalesmanID = @SalesmanID)
Begin
	Set @ErrorMsg = 'Invalid SalesmanID [' + Cast(@SalesmanID as nVarchar(20)) + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
	Goto Out
End

---- To check whether Asset type Exist in Asset type Master, if AssetType has value
--If @AssetType <> ''
--Begin
--	Select @ExistAssetType = IsNull(AssetType, '') From AssetMaster Where AssetType = @AssetType
--	If @ExistAssetType = ''
--	Begin
--		Set @ErrorMsg = 'Invalid Asset Type [' + @AssetType + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
--		Goto Out
--	End
--End

-- To check whether SalesmanID is mapped to CustomerID
If Not Exists(Select SalesmanID From Beat_Salesman Where CustomerID = @CustomerID and SalesmanID = @SalesmanID)
Begin
	Set @ErrorMsg = 'SalesmanID [' + Cast(@SalesmanID as nVarchar(20)) + '] is not mapped to CustomerID [' + @CustomerID + '] .'
	Goto Out
End

-- To Validate Asset Status
If Not (@AssetStatus = 'New' or @AssetStatus = 'Verified' or @AssetStatus = 'Rejected')
Begin
	Set @ErrorMsg = 'Invalid Asset Status [' + @AssetStatus + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
	Goto Out	
End

-- To Validate Source
If Not (@Source = 'HH')
Begin
	Set @ErrorMsg = 'Invalid Source [' + @Source + '] for CustomerID [' + @CustomerID + '] and Asset Number [' + @AssetNumber + '].'
	Goto Out	
End

--To check existing CustomerID is Active or Not
If @ExistCustomerID <> '' and @Active = 0
Begin
	Set @ErrorMsg = 'Asset processed but CustomerID [' + @CustomerID + '] is inactive.'
	Goto Out
End

Out:
Select @ErrorMsg, @Active

