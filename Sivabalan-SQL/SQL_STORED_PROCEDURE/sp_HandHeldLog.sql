Create Procedure dbo.sp_HandHeldLog (@FromDate DateTime, @Todate DateTime)
As
Begin
	Set DateFormat DMY

	Set @FromDate = dbo.StripTimeFromDate(@FromDate)
	Set @Todate = dbo.StripTimeFromDate(@Todate)
	
	Select I.LogID, I.LogID, I.SalesmanID, S.Salesman_Name [Salesman Name], Cast(I.CreationDate as nvarchar) [CreationDate],
	Case isnull(I.Status, 0) When 0 Then 'Not Processed'
		When 1 Then 'Running'
		When 2 Then 'Processed' End  [Status]
	From Inbound_Status I, Salesman S
	Where dbo.StripTimeFromDate(I.CreationDate) Between @FromDate and @Todate
	and I.SalesmanID = S.SalesmanID
	Order By S.Salesman_Name, I.CreationDate
	
End
