CREATE Function fn_GetSalesManNameForCustomer
(@cuscode nvarchar(30)) Returns nvarchar(100)
as
begin
	declare @SalesmanName nvarchar(510)
	Set @SalesmanName=dbo.LookupDictionayItem(N'No SalesMan',default)

	Select @SalesmanName=SalesMan_Name From SalesMan,Beat_SalesMan 
	Where SalesMan.SalesManID=Beat_SalesMan.SalesManid
	And BEat_SalesMan.Customerid=@cuscode

Return(@SalesmanName)
end


