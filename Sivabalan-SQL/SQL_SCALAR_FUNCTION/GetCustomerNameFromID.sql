
CREATE Function dbo.GetCustomerNameFromID (@CustomerID nVarchar(15))
Returns Nvarchar(255)
As
Begin
Declare @CustomerName NVarchar(255)
Select @CustomerName=Company_Name From Customer Where CustomerID = @CustomerID And Active = 1
Return (@CustomerName)
End

