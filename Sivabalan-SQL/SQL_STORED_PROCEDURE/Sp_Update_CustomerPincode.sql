Create procedure Sp_Update_CustomerPincode
(
 @CustomerID nvarchar(15), 
 @Pincode nvarchar(10)
)
As
Begin
	IF isnull(@Pincode,'') <> ''
		Update Customer Set Pincode = @Pincode Where CustomerID=@CustomerID
End
