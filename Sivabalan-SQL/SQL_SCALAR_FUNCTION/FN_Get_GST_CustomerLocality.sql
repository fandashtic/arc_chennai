Create Function FN_Get_GST_CustomerLocality(@CustomerID nvarchar(30))
	Returns int
As
Begin
	Declare @CustomerShippingStateID int
	Declare @CompanyShippingStateID int
	Declare @CustomerLocality int

	Select @CustomerShippingStateID = isnull(BillingStateID,0) From Customer Where CustomerID = @CustomerID
	Select Top 1 @CompanyShippingStateID = isnull(ShippingStateID,0) From Setup
	
	IF @CustomerShippingStateID =  @CompanyShippingStateID
		Set @CustomerLocality = 1
	Else
		Set @CustomerLocality = 2
	
	Return @CustomerLocality
End
