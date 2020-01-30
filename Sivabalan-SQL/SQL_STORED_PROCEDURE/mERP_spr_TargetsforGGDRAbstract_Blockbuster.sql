Create Procedure mERP_spr_TargetsforGGDRAbstract_Blockbuster(@GGDRmonth Nvarchar(10),@RecdDSType Nvarchar(4000),@DS Nvarchar(4000),@Beat Nvarchar(4000))
As
Begin
	Set DateFormat DMY
	Declare @OCGFlag as Int
	Set @OCGFlag = (Select Top 1 isnull(flag,0) from tbl_merp_Configabstract where ScreenCode = 'OCGDS')
	Declare @Delimeter as nVarchar
	Set @Delimeter = Char(15)

	Create Table #TmpCustomer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				SalesmanID Int,
				Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #T_Customer (CustomerID Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,SalesmanID Int)
	Create Table #TmpDS (SalesmanID Int)
	Create Table #TmpBeat (Beat Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create Table #TmpDSType (DSType Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	If @DS = '%'
	Begin
		Insert Into #TmpDS Select SalesmanID From Salesman
	End
	Else
	Begin
		Insert Into #TmpDS    
		Select SalesmanID From Salesman Where Salesman_Name In (Select * From dbo.sp_splitin2Rows(@DS,@Delimeter))    
	End

	If @Beat = '%'
	Begin
		Insert Into #TmpBeat Select Description From Beat
	End
	Else
	Begin
		Insert Into #TmpBeat    
		Select Description From Beat Where Description In (Select * From dbo.sp_splitin2Rows(@Beat,@Delimeter))    
	End

	If @RecdDSType = '%'
	Begin
		Insert Into #TmpDSType Select Distinct DSTypevalue From DSType_Master
	End
	Else
	Begin
		Insert Into #TmpDSType    
		Select  DSTypevalue From DSType_Master Where DSTypevalue In (Select * From dbo.sp_splitin2Rows(@RecdDSType,@Delimeter))    
	End

	select * into #tmpInvalidCust From (select Distinct CustomerID from GGRRFinalData 
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime) and isnull(Flag,'') <> 'WS') T

	Insert Into #T_Customer(CustomerID,SalesmanID)
	select Distinct CustomerID,DSID from GGRRFinalData 
	Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime) and isnull(Flag,'') <> 'WS'
	Union
	select Distinct G.OutletID as CustomerID,BS.SalesManID as DSID from ggdroutlet G,Beat_salesMan BS
	where G.OutletID = BS.CustomerID and cast('01-'+ @GGDRmonth as DateTime) between G.ReportFromDate and G.ReportToDate
	and G.OutletID not in (select Distinct CustomerID from #tmpInvalidCust) and isnull(G.Flag,'') <> 'WS'

	
	Insert Into #T_Customer(CustomerID,SalesmanID)
	Select Distinct CustomerID,SalesmanID From Beat_Salesman Where CustomerID in (Select Distinct CustomerID From #T_Customer)
	
	Declare @CustomerID as Nvarchar(255)
	Declare @SalesmanID as Int

	Declare Cur Cursor for
	select Distinct CustomerID,SalesmanID from #T_Customer
	Open Cur
	Fetch from Cur into @CustomerID,@SalesmanID
	While @@fetch_status =0
		Begin

			IF Exists(Select 'X' From Beat_Salesman	Where CustomerID = @CustomerID And SalesmanID = @SalesmanID)
			Begin
				Insert Into #TmpCustomer				
				Select Distinct CustomerID,SalesmanID,B.Description From Beat_Salesman,Beat B
				Where B.BeatID = Beat_Salesman.BeatID And
				CustomerID = @CustomerID And SalesmanID = @SalesmanID
			End
			Else
			Begin 
				Insert Into #TmpCustomer				
				Select @CustomerID,@SalesmanID,''
			End
 
			Fetch Next from Cur into @CustomerID,@SalesmanID
		End
	Close Cur
	Deallocate Cur

	If Exists (Select 'x' From #TmpCustomer Where Isnull(Beat,'') = '')
	Begin
		Insert into #TmpBeat Values ('')
	End

	Delete From #TmpCustomer Where SalesmanID Not in (Select Distinct SalesmanID From #TmpDS)
	Delete From #TmpCustomer Where Beat Not in (Select Distinct Beat From #TmpBeat)

	Select Distinct DetailID,@GGDRmonth [Month],GGRRFinalData.CustomerID [CustomerID],
	CustomerName [Customer Name],DSID [DS ID],S.Salesman_Name [DS Name],DSType [DS Type],B.Beat [Beat],
	Status,Target,TargetUOM,CatGRP [Cat GRP],OCG,Actual,CurrentStatus [Current Status],LastDayCloseDate [Last Day Close Date] 
	from GGRRFinalData,#TmpCustomer B,SalesMan S
	Where B.CustomerID = GGRRFinalData.CustomerID
	And B.SalesmanID = GGRRFinalData.DSID
	And cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)
	And DSType in (Select Distinct DSType From #TmpDSType)
	And DSID in (Select Distinct SalesmanID From #TmpDS)
	And B.Beat in (Select Distinct Beat From #TmpBeat)
	And S.SalesmanID = GGRRFinalData.DSID
	And isnull(GGRRFinalData.Flag,'') <> 'WS'
/*	
	union
	select ',,,,,,'+cast(G.ProdDefnID as nvarchar(50)) as DetailID,@GGDRmonth [Month],G.OutletID [CustomerID],
	C.Company_Name [Customer Name],T.SalesmanID [DS ID],S.Salesman_Name [DS Name],FN.DSType as [DS Type],T.Beat as [Beat],
	Case G.OutletStatus 
	When 'R' Then 'Red'
	When 'EG' Then 'Eligible For Green' End,
	G.Target,
	Case G.TargetUOM 
	When 1 Then 'Base UOM'
	When 2 Then 'UOM1'
	When 3 Then 'UOM2'
	When 4 then 'Value' End,
	G.CatGroup,
	G.OCG,
	0,
	Case G.OutletStatus 
	When 'R' Then 'Red'
	When 'EG' Then 'Eligible For Green' End,
	(Select Top 1 LastInventoryUpload from Setup)
	from #TmpCustomer T,GGDROutlet G,Customer C,Beat_Salesman BS,Salesman S,dbo.mERP_FN_getDSDStype_GGRRReport(@OCGFlag) FN 
	where 	T.customerID+cast(T.SalesmanID as nvarchar(50)) not in 
	(select customerID+cast(DSID as nvarchar(50)) from ggrrfinaldata Where cast('01-' + [Month] as dateTime) = cast('01-'+ @GGDRmonth as DateTime)) and
	T.CustomerID = G.OutletID And
	T.CustomerID = C.CustomerID And
	BS.CustomerID = C.CustomerID And
	BS.SalesmanID = S.SalesmanID And
	S.Salesmanid=FN.DSID And
	s.salesmanid=t.salesmanid and
	isnull(s.active,0)=1 and 
	cast('01-' + @GGDRmonth as dateTime) between G.ReportFromDate and G.ReportToDate
	And (FN.CategoryGroup = G.OCG or FN.CategoryGroup = G.CatGroup)
*/
	Drop Table #TmpDS
	Drop Table #TmpBeat
	Drop Table #TmpDSType
	Drop Table #TmpCustomer
	Drop Table #T_Customer
	Drop Table #tmpInvalidCust
End
