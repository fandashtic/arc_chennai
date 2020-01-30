Create Procedure Sp_PreparePendingGGRRFinalData
As
Begin
	Truncate Table PendingGGRRFinalDataPost

	Declare @DayClose as DateTime
	Set @DayClose = (Select Top 1 lastInventoryUpload From Setup)

	Insert Into PendingGGRRFinalDataPost
	Select Distinct Fromdate,Todate,OutletID,Cast(('01-' + Fromdate) as DateTime),
	(Case When @DayClose >= (DateAdd(d,-1,DateAdd(m,+1,Cast(('01-' + Fromdate) as DateTime)))) Then (DateAdd(d,-1,DateAdd(m,+1,Cast(('01-' + Fromdate) as DateTime)))) 
		 Else @DayClose End)
	From GGDROutlet Where Isnull(IsReceived,0) = 1
End
