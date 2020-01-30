create procedure sp_acc_getcodefromaccountid(@Accountid int,@Type int)
as
Declare @CustomerCode nVarchar(20)
Declare @VendorCode nvarchar(20)
If @Type = 1
Begin
	Select CustomerID from Customer
	where AccountID = @AccountID

End
Else If @Type = 2
Begin
	Select VendorID from Vendors
	Where AccountID = @AccountID
End 








