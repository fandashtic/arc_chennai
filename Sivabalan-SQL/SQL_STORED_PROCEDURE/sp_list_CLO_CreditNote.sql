CREATE procedure sp_list_CLO_CreditNote
(
	@LoyaltyType nVarchar(15),              
    @FromDate datetime,              
    @ToDate datetime, 
	@Status Int,
	@ActStatus Int 
)              
As
	Create Table #tmpResult(ID int,[Loyalty Program] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Outlet Code] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Outlet Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[Month] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,[Reference No] nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Amount decimal(18,6),Status nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CLOMonth nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	IF @LoyaltyType = N'%' 
		Insert into #tmpResult(ID,[Loyalty Program],[Outlet Code],[Outlet Name],[Month],[Reference No],Amount,Status,CLOMonth)
		Select cln.ID, "Loyalty Program" = cln.CLOType, "Outlet Code" = cln.CustomerID, 
			"Outlet Name" = cus.Company_Name, 
			"Month" = Substring(DateName(m, cln.CLODate), 1, 3) + '-' + DateName(yy, cln.CLODate), 
			"Reference No" = cln.RefNumber, 
			"Amount" = cln.Amount, 
			"Status" = (Case When IsNull(cln.IsGenerated, 0) = 0 And cln.Active = 0 Then 'Cancelled' 
							 When IsNull(cln.IsGenerated, 0) = 0 And cln.Active = 1 Then 'Pending' Else 'Processed' End),CLN.CLOMonth 
		From CLOCrNote cln, Customer cus, Loyalty ly 
		Where cln.CLOType = ly.LoyaltyName And   
			cln.CustomerID = cus.CustomerID And 
			cln.CLODate Between @FromDate And @ToDate And 
			IsNull(cln.IsGenerated, 0) = (Case @Status When 0 Then IsNull(cln.IsGenerated, 0) 
													   When 1 Then 1 Else 0 End) And 
			IsNull(cln.Active, 0) = (Case @ActStatus When 0 Then IsNull(cln.Active, 0) 
													   When 1 Then 1 Else 0 End)
		Order By cln.CLOType, cln.CLODate

	Else
		Insert into #tmpResult(ID,[Loyalty Program],[Outlet Code],[Outlet Name],[Month],[Reference No],Amount,Status,CLOMonth)
		Select cln.ID, "Loyalty Program" = cln.CLOType, "Outlet Code" = cln.CustomerID,
			"Outlet Name" = cus.Company_Name, 
			"Month" = Substring(DateName(m, cln.CLODate), 1, 3) + '-' + DateName(yy, cln.CLODate), 
			"Reference No" = cln.RefNumber, 
			"Amount" = cln.Amount, 
			"Status" = (Case When IsNull(cln.IsGenerated, 0) = 0 And cln.Active = 0 Then 'Cancelled' 
							 When IsNull(cln.IsGenerated, 0) = 0 And cln.Active = 1 Then 'Pending' Else 'Processed' End),CLN.CLOMonth   
		From CLOCrNote cln, Customer cus, Loyalty ly
		Where  cln.CLOType = ly.LoyaltyName And 
			cln.CustomerID = cus.CustomerID And 
			ly.LoyaltyID = @LoyaltyType And 
			cln.CLODate Between @FromDate And @ToDate And 
			IsNull(cln.IsGenerated, 0) = (Case @Status When 0 Then IsNull(cln.IsGenerated, 0) 
													   When 1 Then 1 Else 0 End) And 
			IsNull(cln.Active, 0) = (Case @ActStatus When 0 Then IsNull(cln.Active, 0) 
													   When 1 Then 1 Else 0 End)
		Order By cln.CLOType, cln.CLODate

	if @Status=0 and (@ActStatus=1 or @ActStatus=0)
	Begin	
		update #tmpResult set Status='Submitted' where [Loyalty Program]+[CLOMonth] in
		(select CLOType+[CLOMonth] from CLOCrNote where active=1 and isnull(isRFAClaimed,0)=1)

		update #tmpResult set Status='Expired' where [Loyalty Program]+[CLOMonth]+[Outlet Code] in
		(select CLOType+[CLOMonth]+[CustomerID] from CLOCrNote where active=1 and isnull(isRFAClaimed,0)=0) and Status='Submitted'
	End
	Else
	Begin
		Delete from #tmpResult where [Loyalty Program]+[CLOMonth] in
		(select CLOType+[CLOMonth] from CLOCrNote where active=1 and isnull(isRFAClaimed,0)=1)
	End
	select ID,[Loyalty Program],[Outlet Code],[Outlet Name],[Month],[Reference No],Amount,Status from #tmpResult
	Drop Table #tmpResult
		
