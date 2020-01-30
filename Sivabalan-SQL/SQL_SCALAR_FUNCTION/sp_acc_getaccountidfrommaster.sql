CREATE Function sp_acc_getaccountidfrommaster(@Code nVarchar(128),@Mode Int)
Returns Int
As
Begin
Declare @AccountID Int
If @Mode = 1
Begin
	Select @AccountID=IsNull(AccountID,0) from Customer
	Where CustomerID = @Code 
End
Else If @Mode = 2
Begin
	Select @AccountID=IsNull(AccountID,0) from Vendors
	Where VendorID = @Code 
End
Else If @Mode = 3
Begin
	Select @AccountID=IsNull(AccountID,0) from Bank
	Where Account_Number = @Code 
End
Else If @Mode = 4
Begin
	Select @AccountID=IsNull(AccountID,0) from WareHouse
	Where WareHouseID = @Code 
End
Return IsNull(@AccountID,0)
End


