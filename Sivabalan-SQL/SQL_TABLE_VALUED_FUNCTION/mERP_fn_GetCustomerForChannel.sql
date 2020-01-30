
Create Function mERP_fn_GetCustomerForChannel(@Channel nVarchar(4000))
Returns @Customer Table (Customer nVArchar(255))
As
Begin
	Declare @Delimiter as Char(1)
	Set @Delimiter = Char(44)
	If @Channel = '%%'
		Insert Into @Customer Select CustomerID From Customer
	Else
		Insert Into @Customer Select CustomerID From Customer
			Where ChannelType In (Select ChannelType From Customer_Channel
					Where ChannelDesc In(Select * From dbo.sp_SplitIn2Rows(@Channel, @Delimiter)))
	Return
End

