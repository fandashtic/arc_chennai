
CREATE Function dbo.GetSalesManNameFromID (@SalesManID Int)
Returns Nvarchar(255)
As
Begin
Declare @SalesManName NVarchar(255)
Select @SalesManName=SalesMan_Name From SalesMan Where SalesManID = @SalesManID And Active = 1
Return (@SalesManName)
End

